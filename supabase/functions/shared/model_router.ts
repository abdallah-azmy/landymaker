// =========== ENVIRONMENT VARIABLES ===========
// Imported via Deno.env in the consuming function.
// Keys are read at the call site to avoid circular dependencies.

// =========== CIRCUIT BREAKER ===========
export interface CircuitState {
  failures: number;
  lastFailure: number;
  isOpen: boolean;
}

const circuitBreakers: Record<string, CircuitState> = {};
const CIRCUIT_THRESHOLD = 3;
const CIRCUIT_RESET_MS = 5 * 60 * 1000;

export function isCircuitOpen(provider: string): boolean {
  const state = circuitBreakers[provider];
  if (!state || !state.isOpen) return false;
  if (Date.now() - state.lastFailure > CIRCUIT_RESET_MS) {
    circuitBreakers[provider] = { failures: 0, lastFailure: 0, isOpen: false };
    return false;
  }
  return true;
}

export function recordFailure(provider: string) {
  const state = circuitBreakers[provider] || { failures: 0, lastFailure: 0, isOpen: false };
  state.failures++;
  state.lastFailure = Date.now();
  if (state.failures >= CIRCUIT_THRESHOLD) {
    state.isOpen = true;
    console.warn(`⚠️ Circuit breaker OPEN for provider: ${provider}`);
  }
  circuitBreakers[provider] = state;
}

export function recordSuccess(provider: string) {
  circuitBreakers[provider] = { failures: 0, lastFailure: 0, isOpen: false };
}

// =========== MODEL RESULT TYPE ===========
export interface ModelResult {
  text: string;
  provider: string;
  model: string;
}

// =========== FETCH WITH RETRY ===========
export async function fetchWithRetry(
  url: string, options: RequestInit, retries = 2, delay = 1000
): Promise<Response> {
  for (let i = 0; i < retries; i++) {
    const res = await fetch(url, options);
    if (res.status === 429 || res.status === 503) {
      console.warn(`Attempt ${i + 1} status ${res.status}. Retry in ${delay}ms...`);
      await new Promise(r => setTimeout(r, delay));
      delay *= 1.5;
      continue;
    }
    const clone = res.clone();
    try {
      const json = await clone.json();
      if (json.error?.message?.includes("high demand") ||
          json.error?.message?.includes("quota") ||
          json.error?.message?.includes("Quota exceeded")) {
        console.warn(`Transient error: ${json.error.message}. Retry in ${delay}ms...`);
        await new Promise(r => setTimeout(r, delay));
        delay *= 1.5;
        continue;
      }
    } catch { /* ignore */ }
    return res;
  }
  return await fetch(url, options);
}

// =========== CORS HEADERS ===========
export const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

// =========== GEMINI MODEL CACHE ===========
let cachedGeminiModel: string | null = null;
let lastGeminiModelFetch = 0;
const GEMINI_CACHE_TTL = 30 * 60 * 1000;

export async function getBestActiveGeminiModel(googleAiKey: string): Promise<string> {
  const now = Date.now();
  if (cachedGeminiModel && (now - lastGeminiModelFetch < GEMINI_CACHE_TTL)) {
    return cachedGeminiModel;
  }

  try {
    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models?key=${googleAiKey}`
    );
    if (!response.ok) throw new Error(`Failed to list models: ${response.statusText}`);
    const data = await response.json();
    const modelsList = data.models || [];

    const preferenceOrder = [
      'gemini-2.5-flash',
      'gemini-1.5-flash-latest',
      'gemini-1.5-flash',
      'gemini-2.0-flash-exp',
      'gemini-2.0-flash',
    ];

    const activeModels = modelsList
      .filter((m: any) =>
        m.supportedGenerationMethods?.includes('generateContent') &&
        m.name?.startsWith('models/gemini-')
      )
      .map((m: any) => m.name.replace('models/', ''));

    let bestModel = preferenceOrder.find(m => activeModels.includes(m)) || '';
    if (!bestModel && activeModels.length > 0) {
      bestModel = activeModels.find((n: string) => n.includes('flash')) || activeModels[0];
    }
    if (!bestModel) bestModel = 'gemini-1.5-flash-latest';

    cachedGeminiModel = bestModel;
    lastGeminiModelFetch = now;
    return bestModel;
  } catch (e) {
    console.error("Gemini model fetch failed, using default:", e);
    return 'gemini-1.5-flash-latest';
  }
}

// =========== PROVIDER: GEMINI ===========
export async function tryGeminiProvider(
  prompt: string, googleAiKey: string, responseMimeType?: string
): Promise<ModelResult | null> {
  if (!googleAiKey) { console.warn("Skipping Gemini: no API key"); return null; }
  if (isCircuitOpen('gemini')) { console.warn("Skipping Gemini: circuit open"); return null; }

  const bestModel = await getBestActiveGeminiModel(googleAiKey);
  const models = [...new Set([
    bestModel,
    'gemini-2.5-flash',
    'gemini-2.0-flash',
    'gemini-1.5-flash-latest',
    'gemini-1.5-flash',
  ])];

  for (const model of models) {
    try {
      const body: any = {
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { temperature: 0.7, topP: 0.8, topK: 40 },
      };
      if (responseMimeType) {
        body.generationConfig.response_mime_type = responseMimeType;
      }

      const res = await fetchWithRetry(
        `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${googleAiKey}`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(body),
        }
      );
      const data = await res.json();
      if (data.error) {
        console.warn(`Gemini ${model} error: ${data.error.message}`);
        continue;
      }
      if (data.candidates?.[0]?.content?.parts?.[0]?.text) {
        recordSuccess('gemini');
        return { text: data.candidates[0].content.parts[0].text, provider: 'gemini', model };
      }
      console.warn(`Gemini ${model}: no candidates`);
    } catch (e: any) {
      console.warn(`Gemini ${model} exception:`, e.message || e);
    }
  }

  recordFailure('gemini');
  return null;
}

// =========== OPENAI-COMPATIBLE PROVIDER ===========
export async function tryOpenAICompatibleProvider(
  provider: string,
  apiKey: string,
  baseUrl: string,
  models: string[],
  prompt: string,
  extraOptions?: { temperature?: number; maxTokens?: number },
): Promise<ModelResult | null> {
  if (!apiKey) { console.warn(`Skipping ${provider}: no API key`); return null; }
  if (isCircuitOpen(provider)) { console.warn(`Skipping ${provider}: circuit open`); return null; }

  for (const model of models) {
    try {
      const res = await fetch(`${baseUrl}/v1/chat/completions`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${apiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model,
          messages: [{ role: 'user', content: prompt }],
          temperature: extraOptions?.temperature ?? 0.7,
          max_tokens: extraOptions?.maxTokens ?? 8192,
        }),
      });
      if (!res.ok) {
        console.warn(`${provider} ${model} returned ${res.status}`);
        continue;
      }

      const data = await res.json();
      if (data.choices?.[0]?.message?.content) {
        recordSuccess(provider);
        return { text: data.choices[0].message.content, provider, model };
      }
      console.warn(`${provider} ${model}: no content in response`);
    } catch (e: any) {
      console.warn(`${provider} ${model} exception:`, e.message || e);
    }
  }

  recordFailure(provider);
  return null;
}

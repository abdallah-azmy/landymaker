// This file helps IDEs (like AntiGravity or VS Code) recognize Deno globals
// and URL imports when the Deno extension is not active.

declare namespace Deno {
  export interface Env {
    get(key: string): string | undefined;
  }
  export const env: Env;
}

declare module "https://deno.land/std@0.168.0/http/server.ts" {
  export function serve(handler: (req: Request) => Response | Promise<Response>, options?: { port?: number }): void;
}

declare module "https://esm.sh/@supabase/supabase-js@2.39.3" {
  export interface SupabaseClient {
    from(table: string): any;
    auth: any;
    rpc(fn: string, params?: any): Promise<any>;
    functions: any;
    storage: any;
  }
  export function createClient(supabaseUrl: string, supabaseKey: string, options?: any): SupabaseClient;
}

// Support for other variations that might be used
declare module "https://esm.sh/@supabase/supabase-js@2" {
  export { createClient, SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";
}

declare module "std/http/server.ts" {
  export { serve } from "https://deno.land/std@0.168.0/http/server.ts";
}

declare module "supabase" {
  export { createClient, SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";
}

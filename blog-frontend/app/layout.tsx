import type { Metadata } from "next";
import "./globals.css";
import { Cairo } from "next/font/google";

const cairo = Cairo({ subsets: ["arabic"], variable: "--font-cairo" });

export const metadata: Metadata = {
  metadataBase: new URL('https://landymaker.com'),
  title: "المدونة | LandyMaker",
  description: "مدونة LandyMaker المتخصصة في التجارة الإلكترونية وصفحات الهبوط",
  openGraph: {
    title: "المدونة | LandyMaker",
    description: "مدونة LandyMaker المتخصصة في التجارة الإلكترونية وصفحات الهبوط",
    siteName: 'LandyMaker',
    locale: 'ar_AR',
    type: 'website',
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ar" dir="rtl">
      <body className={`${cairo.variable} font-sans antialiased bg-gray-50 text-gray-900`}>
        {children}
      </body>
    </html>
  );
}

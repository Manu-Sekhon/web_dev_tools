import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Bento Grid Demo - Framer Motion & Lucide",
  description: "Responsive Bento Grid with Framer Motion animations in Next.js",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="dark">
      <body className="antialiased">{children}</body>
    </html>
  );
}

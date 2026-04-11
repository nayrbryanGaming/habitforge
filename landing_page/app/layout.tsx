import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "HabitForge | Forge Better Habits Every Day",
  description: "HabitForge is a modern habit tracking application designed to help you build consistent daily routines through behavioral psychology and streak tracking.",
  keywords: "habit tracker, productivity, consistency, to-do list, habit app",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="scroll-smooth">
      <body className={inter.className}>{children}</body>
    </html>
  );
}

"use client";

import React, { useState } from "react";
import { motion } from "framer-motion";
import {
  Sparkles,
  Zap,
  ShieldCheck,
  BarChart3,
  Globe2,
  ArrowUpRight,
  Cpu,
  Layers,
  CheckCircle2,
  Terminal,
  Activity,
  ChevronRight,
} from "lucide-react";

// --- Types ---
export interface BentoItemProps {
  title: string;
  description: string;
  header?: React.ReactNode;
  icon?: React.ReactNode;
  className?: string;
  badge?: string;
  href?: string;
}

// --- Container Component ---
export function BentoGrid({
  className = "",
  children,
}: {
  className?: string;
  children: React.ReactNode;
}) {
  return (
    <div
      className={`grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 gap-4 max-w-7xl mx-auto p-4 ${className}`}
    >
      {children}
    </div>
  );
}

// --- Item / Card Component ---
export function BentoGridItem({
  title,
  description,
  header,
  icon,
  className = "",
  badge,
  href,
}: BentoItemProps) {
  const [isHovered, setIsHovered] = useState(false);

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-50px" }}
      whileHover={{ y: -5, transition: { duration: 0.25, ease: "easeOut" } }}
      onHoverStart={() => setIsHovered(true)}
      onHoverEnd={() => setIsHovered(false)}
      className={`group relative overflow-hidden rounded-3xl border border-neutral-200 dark:border-neutral-800 bg-white/70 dark:bg-neutral-900/80 backdrop-blur-xl p-6 shadow-sm transition-shadow hover:shadow-xl dark:hover:shadow-neutral-950/60 flex flex-col justify-between ${className}`}
    >
      {/* Animated Subtle Spotlight Gradient */}
      <motion.div
        className="pointer-events-none absolute -inset-px rounded-3xl opacity-0 transition-opacity duration-300 group-hover:opacity-100"
        style={{
          background:
            "radial-gradient(600px circle at var(--mouse-x, 50%) var(--mouse-y, 50%), rgba(99, 102, 241, 0.12), transparent 40%)",
        }}
      />

      {/* Header / Graphic Slot */}
      <div className="w-full flex-1 mb-4 flex items-center justify-center min-h-[140px] rounded-2xl overflow-hidden bg-neutral-50 dark:bg-neutral-950/50 border border-neutral-100 dark:border-neutral-800/60 p-3">
        {header}
      </div>

      {/* Content Meta */}
      <div className="relative z-10 flex flex-col gap-2">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            {icon && (
              <motion.div
                animate={isHovered ? { scale: 1.15, rotate: 5 } : { scale: 1, rotate: 0 }}
                transition={{ type: "spring", stiffness: 400, damping: 15 }}
                className="p-2 rounded-xl bg-indigo-50 dark:bg-indigo-950/50 text-indigo-600 dark:text-indigo-400 border border-indigo-100 dark:border-indigo-900/30"
              >
                {icon}
              </motion.div>
            )}
            {badge && (
              <span className="text-[11px] font-semibold uppercase tracking-wider px-2.5 py-0.5 rounded-full bg-neutral-100 dark:bg-neutral-800 text-neutral-600 dark:text-neutral-300 border border-neutral-200 dark:border-neutral-700">
                {badge}
              </span>
            )}
          </div>

          {href && (
            <motion.a
              href={href}
              animate={isHovered ? { x: 2, y: -2 } : { x: 0, y: 0 }}
              className="text-neutral-400 hover:text-neutral-700 dark:hover:text-neutral-200"
            >
              <ArrowUpRight className="w-5 h-5" />
            </motion.a>
          )}
        </div>

        <div>
          <h3 className="font-semibold text-lg text-neutral-900 dark:text-neutral-100 tracking-tight flex items-center gap-1.5">
            {title}
          </h3>
          <p className="text-sm text-neutral-500 dark:text-neutral-400 mt-1 leading-relaxed line-clamp-3">
            {description}
          </p>
        </div>
      </div>
    </motion.div>
  );
}

// --- Sample Interactive Graphics for Demo ---

function AnalyticsGraphic() {
  return (
    <div className="w-full h-full flex flex-col justify-end gap-2 p-2">
      <div className="flex items-center justify-between text-xs text-neutral-500 mb-1">
        <span className="flex items-center gap-1 font-mono">
          <Activity className="w-3.5 h-3.5 text-emerald-500 animate-pulse" /> +94.8% Realtime
        </span>
        <span className="font-semibold text-indigo-500">Speed Score: 99</span>
      </div>
      <div className="flex items-end gap-2 h-24 w-full">
        {[40, 65, 55, 80, 70, 95, 88, 100].map((h, i) => (
          <motion.div
            key={i}
            initial={{ height: 0 }}
            whileInView={{ height: `${h}%` }}
            transition={{ duration: 0.5, delay: i * 0.05 }}
            className="flex-1 bg-gradient-to-t from-indigo-600 to-violet-400 rounded-t-md opacity-80 group-hover:opacity-100 transition-opacity"
          />
        ))}
      </div>
    </div>
  );
}

function CodeTerminalGraphic() {
  return (
    <div className="w-full font-mono text-xs text-neutral-300 bg-neutral-950 p-3 rounded-xl border border-neutral-800 flex flex-col gap-1.5 shadow-inner">
      <div className="flex items-center gap-1.5 mb-1 pb-1 border-b border-neutral-800 text-neutral-500 text-[10px]">
        <span className="w-2.5 h-2.5 rounded-full bg-rose-500/80" />
        <span className="w-2.5 h-2.5 rounded-full bg-amber-500/80" />
        <span className="w-2.5 h-2.5 rounded-full bg-emerald-500/80" />
        <span className="ml-auto flex items-center gap-1">
          <Terminal className="w-3 h-3" /> deploy.config.ts
        </span>
      </div>
      <p className="text-indigo-400">
        export const <span className="text-emerald-400">edgeCompute</span> = &#123;
      </p>
      <p className="pl-4 text-neutral-400">
        region: <span className="text-amber-300">&apos;global-auto&apos;</span>,
      </p>
      <p className="pl-4 text-neutral-400">
        latency: <span className="text-emerald-400">&apos;&lt; 15ms&apos;</span>
      </p>
      <p className="text-indigo-400">&#125;;</p>
    </div>
  );
}

function SecurityGraphic() {
  return (
    <div className="flex flex-col items-center justify-center gap-2 py-2">
      <div className="relative flex items-center justify-center">
        <motion.div
          animate={{ scale: [1, 1.15, 1], opacity: [0.3, 0.6, 0.3] }}
          transition={{ repeat: Infinity, duration: 3 }}
          className="absolute w-16 h-16 rounded-full bg-emerald-500/20 blur-md"
        />
        <div className="relative p-3 rounded-2xl bg-emerald-50 dark:bg-emerald-950/60 border border-emerald-200 dark:border-emerald-800 text-emerald-600 dark:text-emerald-400 shadow-sm">
          <ShieldCheck className="w-8 h-8" />
        </div>
      </div>
      <div className="flex items-center gap-1.5 text-[11px] font-medium text-emerald-600 dark:text-emerald-400 bg-emerald-500/10 px-2.5 py-1 rounded-full">
        <CheckCircle2 className="w-3.5 h-3.5" /> SOC-2 Type II Certified
      </div>
    </div>
  );
}

function GlobalNetworkGraphic() {
  return (
    <div className="relative w-full h-full flex items-center justify-center">
      <Globe2 className="w-16 h-16 text-indigo-400/40 animate-spin" style={{ animationDuration: "30s" }} />
      <div className="absolute inset-0 flex flex-col justify-center items-center gap-1">
        <span className="text-xs font-mono font-bold text-indigo-600 dark:text-indigo-400 bg-indigo-500/10 px-2 py-0.5 rounded-md backdrop-blur-sm">
          320+ Edge Nodes
        </span>
        <span className="text-[10px] text-neutral-400">Sub-millisecond routing</span>
      </div>
    </div>
  );
}

function AutomationGraphic() {
  return (
    <div className="w-full flex flex-col gap-2 p-1">
      {["Trigger: Webhook event", "Run: AI Vector Synthesis", "Action: Sync to Database"].map((step, i) => (
        <div
          key={i}
          className="flex items-center justify-between text-xs px-2.5 py-1.5 rounded-lg bg-neutral-100/80 dark:bg-neutral-800/50 border border-neutral-200/60 dark:border-neutral-700/50"
        >
          <span className="font-mono text-neutral-700 dark:text-neutral-300 text-[11px]">{step}</span>
          <ChevronRight className="w-3.5 h-3.5 text-neutral-400" />
        </div>
      ))}
    </div>
  );
}

// --- Complete Bento Grid Demo Showcase ---
export default function BentoGridDemo() {
  return (
    <section className="py-12 px-4 bg-neutral-50 dark:bg-neutral-950 min-h-screen text-neutral-900 dark:text-neutral-100 flex flex-col items-center justify-center">
      <div className="text-center max-w-2xl mx-auto mb-10">
        <motion.div
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
          className="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-semibold bg-indigo-500/10 text-indigo-600 dark:text-indigo-400 border border-indigo-500/20 mb-3"
        >
          <Sparkles className="w-3.5 h-3.5" /> Next-Gen Architecture
        </motion.div>
        <h2 className="text-3xl sm:text-4xl font-extrabold tracking-tight">
          Engineered for speed, built for scale
        </h2>
        <p className="text-neutral-500 dark:text-neutral-400 mt-2 text-sm sm:text-base">
          Explore the modular features powered by responsive grid layouts and fluid micro-interactions.
        </p>
      </div>

      <BentoGrid>
        {/* Item 1: Large Featured Card */}
        <BentoGridItem
          className="md:col-span-2 lg:col-span-2"
          badge="Analytics"
          title="Predictive AI Telemetry"
          description="Continuous real-time telemetry models optimize response paths with millisecond precision."
          icon={<BarChart3 className="w-5 h-5" />}
          header={<AnalyticsGraphic />}
          href="#analytics"
        />

        {/* Item 2: Security */}
        <BentoGridItem
          className="md:col-span-1 lg:col-span-1"
          badge="Security"
          title="Zero-Trust Enclave"
          description="Isolated execution sandboxes with automated continuous compliance auditing."
          icon={<ShieldCheck className="w-5 h-5" />}
          header={<SecurityGraphic />}
          href="#security"
        />

        {/* Item 3: Global Edge */}
        <BentoGridItem
          className="md:col-span-1 lg:col-span-1"
          badge="Network"
          title="Global Edge"
          description="Instant distribution across 320+ edge locations with zero cold start penalty."
          icon={<Globe2 className="w-5 h-5" />}
          header={<GlobalNetworkGraphic />}
          href="#network"
        />

        {/* Item 4: Automation */}
        <BentoGridItem
          className="md:col-span-1 lg:col-span-1"
          badge="Workflows"
          title="Adaptive Pipelines"
          description="Orchestrate serverless workflows and sync data across providers with 99.999% uptime."
          icon={<Zap className="w-5 h-5" />}
          header={<AutomationGraphic />}
          href="#workflows"
        />

        {/* Item 5: Developer Experience */}
        <BentoGridItem
          className="md:col-span-2 lg:col-span-2"
          badge="DX & API"
          title="TypeScript-First Tooling"
          description="End-to-end type safety, instant hot reload, and automated edge code deployments."
          icon={<Cpu className="w-5 h-5" />}
          header={<CodeTerminalGraphic />}
          href="#developer"
        />

        {/* Item 6: Extensibility */}
        <BentoGridItem
          className="md:col-span-1 lg:col-span-1"
          badge="Ecosystem"
          title="Modular Blocks"
          description="Composable micro-components designed for seamless Tailwind CSS integration."
          icon={<Layers className="w-5 h-5" />}
          header={
            <div className="flex items-center justify-center p-4">
              <div className="grid grid-cols-2 gap-2">
                {[1, 2, 3, 4].map((n) => (
                  <motion.div
                    key={n}
                    whileHover={{ scale: 1.1, rotate: n % 2 === 0 ? 3 : -3 }}
                    className="w-10 h-10 rounded-xl bg-indigo-500/10 border border-indigo-500/20 flex items-center justify-center text-xs font-bold text-indigo-500"
                  >
                    0{n}
                  </motion.div>
                ))}
              </div>
            </div>
          }
          href="#ecosystem"
        />
      </BentoGrid>
    </section>
  );
}

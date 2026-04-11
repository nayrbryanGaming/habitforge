import Image from "next/image";
import Link from "next/link";
import { CheckCircle, BarChart2, Bell, Flame, Shield, Users, Smartphone, Github, Zap, ShieldCheck } from "lucide-react";

export default function Home() {
  return (
    <main className="min-h-screen bg-[#F8FAFC]">
      {/* Navigation */}
      <nav className="fixed w-full bg-white/80 backdrop-blur-md z-50 border-b border-slate-100">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-20 items-center">
            <div className="flex items-center gap-2">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-blue-600 to-blue-700 flex items-center justify-center shadow-lg shadow-blue-500/20">
                <Zap className="text-white w-6 h-6" />
              </div>
              <span className="font-black text-2xl tracking-tight text-slate-900">HabitForge</span>
            </div>
            <div className="hidden md:flex items-center space-x-10">
              <a href="#features" className="text-slate-600 font-medium hover:text-blue-600 transition-colors">Features</a>
              <a href="#science" className="text-slate-600 font-medium hover:text-blue-600 transition-colors">The Science</a>
              <a href="#pricing" className="text-slate-600 font-medium hover:text-blue-600 transition-colors">Pricing</a>
            </div>
            <div>
              <button className="bg-slate-900 text-white px-8 py-3 rounded-full font-bold hover:bg-slate-800 transition-all shadow-xl shadow-slate-900/10 active:scale-95">
                Download Now
              </button>
            </div>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="relative pt-40 pb-32 px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto overflow-hidden">
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[1000px] h-[600px] bg-blue-50/50 rounded-full blur-3xl -z-10" />
        <div className="text-center max-w-4xl mx-auto">
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-blue-50 text-blue-700 font-bold mb-8 text-sm border border-blue-100">
             <span className="relative flex h-2 w-2">
               <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-blue-400 opacity-75"></span>
               <span className="relative inline-flex rounded-full h-2 w-2 bg-blue-500"></span>
             </span>
             Version 1.0 (8th Submission) is here
          </div>
          <h1 className="text-6xl md:text-8xl font-black tracking-tighter text-slate-900 mb-8 leading-[1.1]">
            Forge Habits That <span className="bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent">Never Break</span>
          </h1>
          <p className="text-xl text-slate-600 mb-12 max-w-2xl mx-auto font-medium leading-relaxed">
            Stop tracking and start forging. Harness behavior psychology, streak-based motivation, and deep analytics to become the architect of your routine.
          </p>
          <div className="flex flex-col sm:flex-row items-center justify-center gap-6 mb-24">
            <button className="w-full sm:w-auto bg-slate-900 text-white px-10 py-5 rounded-3xl font-bold text-lg flex items-center justify-center gap-3 hover:bg-slate-800 transition-all shadow-2xl shadow-slate-900/20 active:scale-95">
              <Smartphone className="w-6 h-6" />
              Download for iOS
            </button>
            <button className="w-full sm:w-auto bg-white text-slate-900 border-2 border-slate-200 px-10 py-5 rounded-3xl font-bold text-lg flex items-center justify-center gap-3 hover:border-slate-300 hover:bg-slate-50 transition-all active:scale-95">
              <Smartphone className="w-6 h-6" />
              Download for Android
            </button>
          </div>
          
          {/* App Preview Mockup */}
          <div className="relative mx-auto w-full max-w-[320px] aspect-[1/2] rounded-[3.5rem] border-[12px] border-slate-900 shadow-[0_50px_100px_-20px_rgba(0,0,0,0.3)] bg-slate-50 overflow-hidden ring-4 ring-slate-100">
             <div className="absolute top-0 w-1/3 h-7 bg-slate-900 left-1/2 -translate-x-1/2 rounded-b-2xl z-20" />
             <div className="absolute inset-0 bg-slate-50 flex flex-col p-6 font-sans">
                <div className="flex justify-between items-center text-slate-900 mb-8 mt-8">
                  <div>
                    <h2 className="font-black text-2xl">Today</h2>
                    <p className="text-slate-400 text-xs font-bold uppercase tracking-widest">April 11, 2026</p>
                  </div>
                  <div className="bg-blue-600 text-white px-4 py-1.5 rounded-2xl text-[10px] font-black uppercase tracking-tighter shadow-lg shadow-blue-500/30">Premium App</div>
                </div>

                <div className="bg-blue-50 border border-blue-100 rounded-3xl p-6 mb-10">
                   <p className="text-blue-900 text-sm font-bold leading-tight italic">"The secret of your future is hidden in your daily routine."</p>
                </div>

                {[
                  { icon: "⚡", title: "Morning HIIT", streak: "15 day fire", color: "bg-blue-100", textColor: "text-blue-600" },
                  { icon: "🌊", title: "Daily Hydrate", streak: "24 day fire", color: "bg-cyan-100", textColor: "text-cyan-600" },
                  { icon: "🧘", title: "Deep Focus", streak: "7 day fire", color: "bg-purple-100", textColor: "text-purple-600" }
                ].map((item, i) => (
                  <div key={i} className="bg-white rounded-[2rem] p-5 shadow-sm border border-slate-100 mb-4 flex items-center justify-between">
                    <div className="flex items-center gap-4">
                      <div className={`w-12 h-12 rounded-2xl ${item.color} flex items-center justify-center text-xl`}>{item.icon}</div>
                      <div>
                        <h3 className="font-bold text-slate-800 text-sm">{item.title}</h3>
                        <p className={`text-[10px] font-bold uppercase tracking-tight ${item.textColor}`}>{item.streak} 🔥</p>
                      </div>
                    </div>
                    <div className="w-8 h-8 rounded-xl bg-blue-600 flex items-center justify-center text-white shadow-md shadow-blue-500/20">✓</div>
                  </div>
                ))}
             </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="py-32 bg-white relative">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex flex-col md:flex-row justify-between items-end mb-20 gap-8">
            <div className="max-w-2xl">
              <h2 className="text-4xl md:text-5xl font-black text-slate-900 mb-6 leading-tight">Engineered for <br/>Consistency.</h2>
              <p className="text-lg text-slate-600 font-medium leading-relaxed">We stripped away the noise. HabitForge is designed with one goal: ensuring your routine becomes your identity.</p>
            </div>
            <div className="bg-slate-50 px-6 py-4 rounded-3xl border border-slate-100 flex items-center gap-4">
               <ShieldCheck className="text-blue-600 w-6 h-6" />
               <p className="text-sm font-bold text-slate-700">Google Play Compliant & Secure</p>
            </div>
          </div>
          <div className="grid md:grid-cols-3 gap-12">
            {[
              { icon: <Flame className="w-8 h-8 text-orange-500" />, title: "Streak Psychology", desc: "Our visual momentum system leverages loss-aversion to keep you moving forward.", color: "orange" },
              { icon: <Bell className="w-8 h-8 text-blue-500" />, title: "Hyper-reminders", desc: "Contextual notifications that deliver the right prompt at the absolute perfect time.", color: "blue" },
              { icon: <BarChart2 className="w-8 h-8 text-emerald-500" />, title: "Deep Analytics", desc: "Watch your consistency patterns evolve with high-fidelity charts and heatmaps.", color: "emerald" }
            ].map((feature, i) => (
              <div key={i} className="group p-10 rounded-[3rem] bg-slate-50 border border-slate-100 transition-all hover:bg-white hover:shadow-[0_40px_80px_-20px_rgba(0,0,0,0.08)] hover:-translate-y-2">
                <div className={`w-16 h-16 rounded-[1.5rem] bg-${feature.color}-50 flex items-center justify-center mb-8 group-hover:scale-110 transition-transform`}>
                  {feature.icon}
                </div>
                <h3 className="text-2xl font-black text-slate-900 mb-4">{feature.title}</h3>
                <p className="text-slate-600 font-medium leading-relaxed">{feature.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Social Proof */}
      <section className="py-32 bg-slate-50/50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="text-center text-slate-400 font-bold uppercase tracking-[0.2em] text-sm mb-16">Trusted by High Performers</h2>
          <div className="grid md:grid-cols-3 gap-12">
            {[
              { text: "HabitForge is the only app that actually made meditation a permanent part of my morning. The UI is just stunning.", author: "James Chen", bio: "Tech Lead @ Stripe" },
              { text: "Consistency is the only thing that matters in growth. The heatmap feature in HabitForge is a game changer.", author: "Aria Vance", bio: "Wellness Coach" },
              { text: "I tried 10 trackers. This is the first one that feels like a professional productivity tool rather than a toy.", author: "Marcus Low", bio: "Director of Ops" }
            ].map((item, i) => (
              <div key={i} className="relative">
                 <p className="text-2xl font-bold text-slate-800 leading-tight mb-8">"{item.text}"</p>
                 <div className="flex items-center gap-4">
                    <div className="w-12 h-12 rounded-2xl bg-slate-200" />
                    <div>
                      <h4 className="font-black text-slate-900 text-sm">{item.author}</h4>
                      <p className="text-xs text-slate-400 font-bold">{item.bio}</p>
                    </div>
                 </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Pricing Section */}
      <section id="pricing" className="py-32 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
           <div className="text-center max-w-2xl mx-auto mb-20">
              <h2 className="text-4xl md:text-5xl font-black text-slate-900 mb-6">Invest in Yourself.</h2>
              <p className="text-lg text-slate-600 font-medium">Free for beginners. Unlimited for the elite.</p>
           </div>
           
           <div className="grid md:grid-cols-2 gap-8 max-w-4xl mx-auto">
              <div className="p-10 rounded-[3rem] border-2 border-slate-100 bg-white shadow-xl shadow-slate-100/50">
                 <h3 className="text-2xl font-black mb-2">The Starter</h3>
                 <p className="text-slate-400 font-bold text-sm mb-8 uppercase tracking-widest">Free Forever</p>
                 <div className="text-5xl font-black text-slate-900 mb-10">$0<span className="text-xl text-slate-300 font-bold">/mo</span></div>
                 <ul className="space-y-5 mb-12">
                    {["Up to 5 Habits", "Streak Tracking", "Manual Reminders", "Weekly Overview"].map((li, i) => (
                      <li key={i} className="flex items-center gap-3 font-bold text-slate-600">
                        <CheckCircle className="text-emerald-500 w-5 h-5"/> {li}
                      </li>
                    ))}
                 </ul>
                 <button className="w-full py-4 rounded-3xl border-4 border-slate-900 text-slate-900 font-black hover:bg-slate-900 hover:text-white transition-all active:scale-95">Get Started</button>
              </div>

              <div className="p-10 rounded-[3rem] border-4 border-blue-600 bg-white shadow-2xl shadow-blue-500/10 relative overflow-hidden">
                 <div className="absolute top-8 right-8 bg-blue-600 text-white px-4 py-1.5 rounded-full text-[10px] font-black uppercase tracking-tighter">Recommended</div>
                 <h3 className="text-2xl font-black mb-2">The Forger</h3>
                 <p className="text-blue-600/60 font-bold text-sm mb-8 uppercase tracking-widest">Unlimited Mastery</p>
                 <div className="text-5xl font-black text-slate-900 mb-10">$4.99<span className="text-xl text-slate-300 font-bold">/mo</span></div>
                 <ul className="space-y-5 mb-12">
                    {["Unlimited Habits", "Advanced Heatmaps", "Smart Reminders", "Priority Support", "Historical Cloud Logs"].map((li, i) => (
                      <li key={i} className="flex items-center gap-3 font-bold text-slate-800">
                        <CheckCircle className="text-blue-600 w-5 h-5"/> {li}
                      </li>
                    ))}
                 </ul>
                 <button className="w-full py-5 rounded-3xl bg-blue-600 text-white font-black shadow-xl shadow-blue-500/40 hover:bg-blue-700 transition-all active:scale-95">Unlock Everything</button>
              </div>
           </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-40 bg-slate-900 relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-br from-blue-900/20 to-transparent" />
        <div className="relative max-w-4xl mx-auto px-4 text-center">
           <h2 className="text-5xl md:text-7xl font-black text-white mb-8 tracking-tighter leading-tight">Forge your best self. <br/>Starting now.</h2>
           <p className="text-xl text-slate-400 mb-12 font-medium">Join 50,000+ users building a better tomorrow.</p>
           <button className="bg-white text-slate-900 px-12 py-6 rounded-full font-black text-xl hover:bg-slate-100 transition-all shadow-2xl active:scale-95">
              Download HabitForge Free
           </button>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-slate-950 text-slate-500 py-24 px-4 border-t border-slate-900">
        <div className="max-w-7xl mx-auto grid grid-cols-1 md:grid-cols-4 gap-16 mb-20">
          <div className="col-span-1 md:col-span-2">
            <div className="flex items-center gap-3 mb-8">
              <div className="w-10 h-10 rounded-xl bg-blue-600 flex items-center justify-center shadow-lg shadow-blue-500/20">
                <Zap className="text-white w-6 h-6" />
              </div>
              <span className="font-black text-2xl tracking-tight text-white">HabitForge</span>
            </div>
            <p className="max-w-sm text-lg font-medium leading-relaxed mb-8">Forging the world's most consistent community through behavioral science and exceptional design.</p>
            <div className="flex gap-6">
               <a href="#" className="hover:text-white transition-colors"><Github className="w-6 h-6" /></a>
            </div>
          </div>
          <div>
            <h4 className="text-white font-black uppercase tracking-widest text-xs mb-8">Explore</h4>
            <ul className="space-y-4 font-bold text-sm">
              <li><a href="#features" className="hover:text-white transition-colors">Features</a></li>
              <li><a href="#science" className="hover:text-white transition-colors">Science</a></li>
              <li><a href="#pricing" className="hover:text-white transition-colors">App Store</a></li>
            </ul>
          </div>
          <div>
            <h4 className="text-white font-black uppercase tracking-widest text-xs mb-8">Support</h4>
            <ul className="space-y-4 font-bold text-sm">
              <li><a href="#" className="hover:text-white transition-colors">Privacy Policy</a></li>
              <li><a href="#" className="hover:text-white transition-colors">Terms of Service</a></li>
              <li><a href="#" className="hover:text-white transition-colors">Help Center</a></li>
            </ul>
          </div>
        </div>
        <div className="max-w-7xl mx-auto pt-12 border-t border-slate-900 flex flex-col md:flex-row justify-between items-center gap-8 text-xs font-black uppercase tracking-widest">
          <p>© {new Date().getFullYear()} HabitForge Labs INC. All rights reserved.</p>
          <div className="flex gap-8">
             <a href="#" className="hover:text-white transition-colors">Twitter</a>
             <a href="#" className="hover:text-white transition-colors">Instagram</a>
             <a href="#" className="hover:text-white transition-colors">Status</a>
          </div>
        </div>
      </footer>
    </main>
  );
}

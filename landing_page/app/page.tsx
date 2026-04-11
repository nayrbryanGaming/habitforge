import Image from "next/image";
import Link from "next/link";
import { CheckCircle, BarChart2, Bell, Flame, Shield, Users, Smartphone, Github } from "lucide-react";

export default function Home() {
  return (
    <main className="min-h-screen">
      {/* Navigation */}
      <nav className="fixed w-full bg-white/80 backdrop-blur-md z-50 border-b border-gray-100">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16 items-center">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 rounded-lg bg-brand-blue flex items-center justify-center">
                <CheckCircle className="text-white w-5 h-5" />
              </div>
              <span className="font-bold text-xl text-brand-dark">HabitForge</span>
            </div>
            <div className="hidden md:flex items-center space-x-8">
              <a href="#features" className="text-gray-600 hover:text-brand-blue transition">Features</a>
              <a href="#how-it-works" className="text-gray-600 hover:text-brand-blue transition">How It Works</a>
              <a href="#pricing" className="text-gray-600 hover:text-brand-blue transition">Pricing</a>
            </div>
            <div>
              <button className="bg-brand-blue text-white px-6 py-2 rounded-full font-medium hover:bg-blue-700 transition">
                Get the App
              </button>
            </div>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="pt-32 pb-20 px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto">
        <div className="text-center max-w-4xl mx-auto">
          <h1 className="text-5xl md:text-7xl font-extrabold tracking-tight text-brand-dark mb-8">
            Forge Better Habits <span className="text-brand-blue">Every Day</span>
          </h1>
          <p className="text-xl text-gray-600 mb-10 max-w-2xl mx-auto">
            Harness the power of streak psychology, smart reminders, and beautiful analytics to build the routines you've always wanted.
          </p>
          <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
            <button className="w-full sm:w-auto bg-brand-dark text-white px-8 py-4 rounded-full font-semibold text-lg flex items-center justify-center gap-2 hover:bg-gray-800 transition">
              <Smartphone className="w-5 h-5" />
              Download for iOS
            </button>
            <button className="w-full sm:w-auto bg-white text-brand-dark border-2 border-brand-dark px-8 py-4 rounded-full font-semibold text-lg flex items-center justify-center gap-2 hover:bg-gray-50 transition">
              <Smartphone className="w-5 h-5" />
              Download for Android
            </button>
          </div>
          <div className="mt-16 relative mx-auto w-full max-w-lg aspect-[1/2] rounded-[3rem] border-[14px] border-gray-900 shadow-2xl bg-white overflow-hidden">
             {/* Mockup screen inside */}
             <div className="absolute inset-0 bg-gradient-to-b from-brand-blue to-blue-800 flex flex-col p-6">
                <div className="flex justify-between items-center text-white mb-8 mt-6">
                  <span className="font-bold text-2xl">Today</span>
                  <div className="bg-white/20 px-3 py-1 rounded-full text-sm">3/5 Habits</div>
                </div>
                <div className="bg-white rounded-2xl p-4 shadow-lg mb-4 flex items-center justify-between">
                  <div className="flex items-center gap-4">
                    <div className="w-12 h-12 rounded-full bg-blue-100 flex items-center justify-center text-2xl">💧</div>
                    <div>
                      <h3 className="font-bold text-gray-800">Drink Water</h3>
                      <p className="text-sm text-gray-500">12 day streak 🔥</p>
                    </div>
                  </div>
                  <div className="w-8 h-8 rounded-full bg-green-500 flex items-center justify-center text-white">✓</div>
                </div>
                <div className="bg-white rounded-2xl p-4 shadow-lg mb-4 flex items-center justify-between">
                  <div className="flex items-center gap-4">
                    <div className="w-12 h-12 rounded-full bg-orange-100 flex items-center justify-center text-2xl">🏃</div>
                    <div>
                      <h3 className="font-bold text-gray-800">Morning Run</h3>
                      <p className="text-sm text-gray-500">4 day streak 🔥</p>
                    </div>
                  </div>
                  <div className="w-8 h-8 rounded-full border-2 border-gray-300"></div>
                </div>
                <div className="bg-white rounded-2xl p-4 shadow-lg flex items-center justify-between">
                  <div className="flex items-center gap-4">
                    <div className="w-12 h-12 rounded-full bg-purple-100 flex items-center justify-center text-2xl">📚</div>
                    <div>
                      <h3 className="font-bold text-gray-800">Read 10 Pages</h3>
                      <p className="text-sm text-gray-500">30 day streak 🔥</p>
                    </div>
                  </div>
                  <div className="w-8 h-8 rounded-full bg-green-500 flex items-center justify-center text-white">✓</div>
                </div>
             </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold text-brand-dark mb-4">Why Choose HabitForge?</h2>
            <p className="text-gray-600 max-w-2xl mx-auto">We combine beautiful design with proven psychological mechanics to help you stick to your goals.</p>
          </div>
          <div className="grid md:grid-cols-3 gap-8">
            <div className="p-8 rounded-2xl bg-slate-50 border border-slate-100 transition hover:shadow-lg">
              <div className="w-12 h-12 rounded-xl bg-orange-100 flex items-center justify-center mb-6">
                <Flame className="text-brand-orange w-6 h-6" />
              </div>
              <h3 className="text-xl font-bold text-brand-dark mb-3">Streak Psychology</h3>
              <p className="text-gray-600">Visual streaks motivate you to keep going. The longer the streak, the harder it is to break.</p>
            </div>
            <div className="p-8 rounded-2xl bg-slate-50 border border-slate-100 transition hover:shadow-lg">
              <div className="w-12 h-12 rounded-xl bg-blue-100 flex items-center justify-center mb-6">
                <Bell className="text-brand-blue w-6 h-6" />
              </div>
              <h3 className="text-xl font-bold text-brand-dark mb-3">Smart Reminders</h3>
              <p className="text-gray-600">Set contextual reminders that ping you exactly when you need that gentle push to complete your habit.</p>
            </div>
            <div className="p-8 rounded-2xl bg-slate-50 border border-slate-100 transition hover:shadow-lg">
              <div className="w-12 h-12 rounded-xl bg-green-100 flex items-center justify-center mb-6">
                <BarChart2 className="text-green-600 w-6 h-6" />
              </div>
              <h3 className="text-xl font-bold text-brand-dark mb-3">Deep Analytics</h3>
              <p className="text-gray-600">Analyze your weekly and monthly completion rates. Discover patterns in your consistency.</p>
            </div>
          </div>
        </div>
      </section>

      {/* Testimonials */}
      <section className="py-20 bg-slate-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="text-3xl md:text-4xl font-bold text-center text-brand-dark mb-16">Loved by Productivity Enthusiasts</h2>
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            {[
              { name: "Sarah J.", role: "Student", text: "HabitForge finally helped me establish a consistent study routine. The streak counter is incredibly motivating!" },
              { name: "Michael T.", role: "Software Engineer", text: "Clean, minimal, and does exactly what it needs to. I've read a book every week since using this app." },
              { name: "Elena R.", role: "Startup Founder", text: "The analytics show me exactly where I'm falling off. The premium upgrade is completely worth it for the insights." }
            ].map((testimonial, i) => (
              <div key={i} className="bg-white p-8 rounded-2xl shadow-sm border border-slate-100">
                <div className="flex text-yellow-400 mb-4">
                  {[...Array(5)].map((_, i) => <svg key={i} className="w-5 h-5 fill-current" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/></svg>)}
                </div>
                <p className="text-gray-700 mb-6 font-medium">"{testimonial.text}"</p>
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-slate-200"></div>
                  <div>
                    <h4 className="font-bold text-sm text-brand-dark">{testimonial.name}</h4>
                    <p className="text-xs text-gray-500">{testimonial.role}</p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Pricing */}
      <section id="pricing" className="py-20 bg-white">
        <div className="max-w-3xl mx-auto px-4 text-center">
          <h2 className="text-3xl md:text-4xl font-bold text-brand-dark mb-4">Simple, Transparent Pricing</h2>
          <p className="text-gray-600 mb-12">Start for free, upgrade when you're ready to unlock your full potential.</p>
          
          <div className="grid md:grid-cols-2 gap-8 text-left">
            <div className="border border-slate-200 p-8 rounded-3xl">
              <h3 className="text-2xl font-bold mb-2">Free</h3>
              <p className="text-gray-500 mb-6">Perfect to get started</p>
              <div className="text-4xl font-extrabold mb-8">$0<span className="text-lg text-gray-400 font-normal">/mo</span></div>
              <ul className="space-y-4 mb-8">
                <li className="flex gap-3"><CheckCircle className="text-green-500 w-5 h-5"/> Up to 5 Habits</li>
                <li className="flex gap-3"><CheckCircle className="text-green-500 w-5 h-5"/> Basic Scheduling</li>
                <li className="flex gap-3"><CheckCircle className="text-green-500 w-5 h-5"/> Streak Tracking</li>
              </ul>
              <button className="w-full py-3 rounded-xl border-2 border-brand-dark text-brand-dark font-bold hover:bg-slate-50 transition">Get Started</button>
            </div>
            
            <div className="border-2 border-brand-blue bg-blue-50/50 p-8 rounded-3xl relative">
              <div className="absolute top-0 right-8 transform -translate-y-1/2 bg-brand-blue text-white px-3 py-1 rounded-full text-sm font-bold">Most Popular</div>
              <h3 className="text-2xl font-bold mb-2">Premium</h3>
              <p className="text-gray-500 mb-6">For the truly committed</p>
              <div className="text-4xl font-extrabold mb-8">$4.99<span className="text-lg text-gray-400 font-normal">/mo</span></div>
              <ul className="space-y-4 mb-8">
                <li className="flex gap-3"><CheckCircle className="text-brand-blue w-5 h-5"/> Unlimited Habits</li>
                <li className="flex gap-3"><CheckCircle className="text-brand-blue w-5 h-5"/> Advanced Analytics</li>
                <li className="flex gap-3"><CheckCircle className="text-brand-blue w-5 h-5"/> Custom Reminders</li>
                <li className="flex gap-3"><CheckCircle className="text-brand-blue w-5 h-5"/> Priority Support</li>
              </ul>
              <button className="w-full py-3 rounded-xl bg-brand-blue text-white font-bold hover:bg-blue-700 transition">Upgrade to Premium</button>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-brand-dark text-white text-center px-4">
        <h2 className="text-4xl font-bold mb-6">Ready to transform your life?</h2>
        <p className="text-xl text-gray-400 mb-10 max-w-2xl mx-auto">Join thousands of users who have already forged better versions of themselves.</p>
        <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
          <button className="w-full sm:w-auto bg-brand-blue text-white px-8 py-4 rounded-full font-bold text-lg hover:bg-blue-600 transition">
            Download App Now
          </button>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-slate-900 text-slate-400 py-12 px-4 border-t border-slate-800">
        <div className="max-w-7xl mx-auto grid grid-cols-2 md:grid-cols-4 gap-8 mb-8">
          <div className="col-span-2">
            <div className="flex items-center gap-2 mb-4">
              <div className="w-8 h-8 rounded-lg bg-brand-blue flex items-center justify-center">
                <CheckCircle className="text-white w-5 h-5" />
              </div>
              <span className="font-bold text-xl text-white">HabitForge</span>
            </div>
            <p className="max-w-xs text-sm">Forge powerful habits one day at a time. Designed with behavioral psychology to help you succeed.</p>
          </div>
          <div>
            <h4 className="text-white font-bold mb-4">Legal</h4>
            <ul className="space-y-2 text-sm">
              <li><a href="/privacy_policy.md" className="hover:text-white transition">Privacy Policy</a></li>
              <li><a href="/terms_of_service.md" className="hover:text-white transition">Terms of Service</a></li>
              <li><a href="/data_usage_policy.md" className="hover:text-white transition">Data Usage Policy</a></li>
            </ul>
          </div>
          <div>
            <h4 className="text-white font-bold mb-4">Connect</h4>
            <ul className="space-y-2 text-sm">
              <li><a href="#" className="hover:text-white transition">Twitter</a></li>
              <li><a href="#" className="hover:text-white transition">Support</a></li>
              <li><a href="https://github.com/nayrbryanGaming/habitforge" className="flex items-center gap-2 hover:text-white transition"><Github className="w-4 h-4"/> GitHub</a></li>
            </ul>
          </div>
        </div>
        <div className="max-w-7xl mx-auto text-center text-sm pt-8 border-t border-slate-800">
          © {new Date().getFullYear()} HabitForge. All rights reserved.
        </div>
      </footer>
    </main>
  );
}

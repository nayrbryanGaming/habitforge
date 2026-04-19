import Link from "next/link";

export default function TermsOfService() {
  return (
    <main className="min-h-screen bg-[#F8FAFC] py-32 px-4 sm:px-6 lg:px-8">
      <div className="max-w-4xl mx-auto bg-white p-12 rounded-[2rem] shadow-sm border border-slate-100">
        <Link href="/" className="text-blue-600 font-bold mb-8 block">← Back to Home</Link>
        <h1 className="text-4xl font-black text-slate-900 mb-8">Terms of Service</h1>
        <div className="prose prose-slate max-w-none">
          <p className="text-slate-600 mb-8 font-bold">Last Updated: April 13, 2026</p>
          
          <h2 className="text-2xl font-bold mt-8 mb-4">1. Acceptance of Terms</h2>
          <p className="text-slate-600 mb-4">
            By using HabitForge, you agree to these Terms. You must be at least 18 years old to use the Service.
          </p>

          <h2 className="text-2xl font-bold mt-8 mb-4">2. User accounts</h2>
          <p className="text-slate-600 mb-4">
            You are responsible for your account security and all activities under your credentials.
          </p>

          <h2 className="text-2xl font-bold mt-8 mb-4">3. Subscriptions</h2>
          <p className="text-slate-600 mb-4">
            HabitForge Premium ("The Forger") is available at $4.99/month. Subscriptions auto-renew via the Google Play Store.
          </p>

          <h2 className="text-2xl font-bold mt-8 mb-4 text-red-600">4. Account Deletion</h2>
          <p className="text-slate-600 mb-4">
            You can delete your account via the App Settings (Instant) or by submitting a request through our <Link href="/#data-safety" className="text-blue-600 underline">Data Safety form</Link>. Deletion is permanent and includes all habits, logs, and analytics.
          </p>

          <h2 className="text-2xl font-bold mt-8 mb-4">5. Medical Disclaimer</h2>
          <div className="bg-amber-50 p-6 rounded-2xl border border-amber-100 mb-8 font-medium italic">
            "HabitForge is not a medical application. Always consult a qualified professional before starting any new health or wellness routine."
          </div>

          <h2 className="text-2xl font-bold mt-8 mb-4">6. Limitation of Liability</h2>
          <p className="text-slate-600 mb-4">
            HabitForge is provided "AS IS". We are not liable for incidental or consequential damages.
          </p>

          <h2 className="text-2xl font-bold mt-8 mb-4">7. Contact</h2>
          <p className="text-slate-600 mb-4">
            Inquiries: support@habitforge.app
          </p>
        </div>
      </div>
    </main>
  );
}

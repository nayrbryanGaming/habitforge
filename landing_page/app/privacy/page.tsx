import Link from "next/link";

export default function PrivacyPolicy() {
  return (
    <main className="min-h-screen bg-[#F8FAFC] py-32 px-4 sm:px-6 lg:px-8">
      <div className="max-w-4xl mx-auto bg-white p-12 rounded-[2rem] shadow-sm border border-slate-100">
        <Link href="/" className="text-blue-600 font-bold mb-8 block">← Back to Home</Link>
        <h1 className="text-4xl font-black text-slate-900 mb-8">Privacy Policy</h1>
        <div className="prose prose-slate max-w-none">
          <p className="text-slate-600 mb-8 font-bold">Last Updated: April 11, 2026</p>
          
          <h2 className="text-2xl font-bold mt-8 mb-4">1. Information We Collect</h2>
          <p className="text-slate-600 mb-4">
            We collect information you provide directly to us (name, email) and usage data regarding your interactions with habit logs to provide a personalized experience.
          </p>

          <h2 className="text-2xl font-bold mt-8 mb-4">2. Use of Data</h2>
          <p className="text-slate-600 mb-4">
            Data is used to maintain services, notify you of updates, provide support, and analyze usage patterns to improve the HabitForge experience.
          </p>

          <h2 className="text-2xl font-bold mt-8 mb-4">3. Data Safety & Security</h2>
          <p className="text-slate-600 mb-4">
            Your data is stored securely using Firebase (Google Cloud). We implement industry-standard encryption and security measures to protect your information.
          </p>

          <h2 className="text-2xl font-bold mt-8 mb-4 text-red-600">4. Account Deletion & The Right to be Forgotten</h2>
          <div className="bg-red-50 p-6 rounded-2xl border border-red-100 mb-8">
            <p className="text-slate-900 font-bold mb-2">Immediate and Permanent Data Purge</p>
            <p className="text-slate-600 mb-4">
              HabitForge respects your right to privacy. You can delete your account and all associated data at any time:
            </p>
            <ul className="list-disc ml-6 text-slate-600 space-y-2">
              <li><strong>In-App:</strong> Settings → Delete Account (Instant automated purge)</li>
              <li><strong>Web Request:</strong> Use the form in our <Link href="/#data-safety" className="text-blue-600 underline">Data Safety section</Link></li>
              <li><strong>Email:</strong> Contact legal@habitforge.app</li>
            </ul>
            <p className="text-slate-600 mt-4 text-sm italic">
              Upon confirmation, all habits, logs, streaks, analytics, and credentials are permanently erased from our production servers.
            </p>
          </div>

          <h2 className="text-2xl font-bold mt-8 mb-4">5. Children's Privacy</h2>
          <p className="text-slate-600 mb-4">
            HabitForge is not intended for children under 13. We do not knowingly collect data from children.
          </p>

          <h2 className="text-2xl font-bold mt-8 mb-4">6. Contact Us</h2>
          <p className="text-slate-600 mb-4">
            For any privacy concerns, contact us at legal@habitforge.app
          </p>
        </div>
      </div>
    </main>
  );
}

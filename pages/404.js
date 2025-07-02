import Link from 'next/link'

export default function Custom404() {
    return (
        <div className="min-h-screen flex flex-col items-center justify-center bg-white text-slate-900 px-4">
            <h1 className="text-5xl font-light mb-6">404 – Page Not Found</h1>
            <p className="text-lg text-slate-600 mb-8 text-center max-w-md">
                Sorry, the page you are looking for doesn't exist or has been moved.
            </p>
            <Link href="/" className="rams-button-primary">
                Go back home
            </Link>
        </div>
    )
} 
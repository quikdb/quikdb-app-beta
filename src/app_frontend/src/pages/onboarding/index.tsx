import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import toast from 'react-hot-toast'

const Onboarding = () => {
    return (
        <main className='min-h-screen p-10 py-7'>
            <header>
                <p className='text-gradient'>quikdb</p>
            </header>
            <div className='container mx-auto p-4'>
                <div className='text-center'>
                    <p>Create an account</p>
                    <p className='text-sm font-light text-gray-200'>Enter your email to sign up for this app</p>
                </div>
                <Input />
            </div>
        </main>
    )
}

export default Onboarding
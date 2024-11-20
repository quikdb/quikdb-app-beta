import { Button } from '@/components/ui/button'
import { Link } from 'react-router-dom'

const Onboarding = () => {
    return (
        <main className='min-h-screen p-10 py-7'>
            <header>
                <p className='text-gradient'>quikdb</p>
            </header>
            <div className='flex flex-col mt-20 gap-7'>
                <Link to="/signup" className='container'>
                    <Button className='bg-gradient'>Go to Signup</Button>
                </Link>
                <Link to="/login" className='container'>
                    <Button className='bg-gradient'>Go to Login</Button>
                </Link>
                <Link to="/organizations" className='container'>
                    <Button className='bg-gradient'>Go to Organizations</Button>
                </Link>
                <Link to="/dashboard" className='container'>
                    <Button className='bg-gradient'>Go to Dashboard</Button>
                </Link>
            </div>

        </main>
    )
}

export default Onboarding
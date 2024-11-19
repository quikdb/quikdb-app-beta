import { Button } from '@/components/ui/button'
import { Link } from 'react-router-dom'

const Onboarding = () => {
    return (
        <main className='min-h-screen p-10 py-7'>
            <header>
                <p className='text-gradient'>quikdb</p>
            </header>
            <Link to="organizations" className='container mt-20'>
                <Button className='bg-gradient'>Go to Organizations</Button>
            </Link>
        </main>
    )
}

export default Onboarding
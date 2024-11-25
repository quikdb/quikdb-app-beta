import { Card } from '@/components/ui/card'
import Input from '@/components/onboarding/Input'
import { PlusIcon, Search } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Label } from '@/components/ui/label'
import { CollaboratorsTable } from './components/collaborators-table'
import { Link } from 'react-router-dom'

const Collaborators = () => {
    return (
        <Card className="bg-transparent text-white border-none p-5 px-0">
            <div className="flex items-center relative mb-5">
                <Label className="absolute left-4 text-gray-400"><Search size={14} /></Label>
                <Input placeholder="Search by project name..." className="pl-10 border border-[#242527] py-3" />
                <Link to="/dashboard/add_collaborators" className='absolute right-5'>
                    <Button variant="outline" className="bg-gradient text-[#0F1407] border-none px-4 w-fit">
                        <PlusIcon className="text-white border border-dotted rounded-lg" />
                        Add Collaborators
                    </Button>
                </Link>
            </div>

            <div className="w-full">
                <CollaboratorsTable />
            </div>

        </Card>
    )
}

export default Collaborators
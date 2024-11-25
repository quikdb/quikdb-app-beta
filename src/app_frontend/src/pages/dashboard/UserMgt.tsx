import { Button } from "@/components/ui/button"
import { OrgUsersTable } from "./components/orguser-table"
import { PlusIcon } from "lucide-react"

const Projects = () => {
    return (
        <div className="mt-10">
            <div className="flex justify-between">
                <div className="flex flex-col gap-1">
                    <p className="font-satoshi_medium text-3xl">Projects</p>
                    <p className="font-satoshi_light text-base text-gray-400">Real-time overview of your listed projects</p>
                </div>
                <Button size="lg" className="font-satoshi_medium bg-gradient px-4 w-fit text-[#0F1407]">
                    <PlusIcon className="text-white border border-dotted rounded-lg" />
                    Invite People
                </Button>
            </div>
            <div>
                <OrgUsersTable />
            </div>
        </div>
    )
}

export default Projects
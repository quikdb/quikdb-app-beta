import { Button } from "@/components/ui/button"
import { DataTableDemo } from "./data-table"

const Projects = () => {
    return (
        <div className="mt-10">
            <div className="flex justify-between">
                <div className="flex flex-col gap-1">
                    <p className="font-satoshi_medium text-3xl">Projects</p>
                    <p className="font-satoshi_light text-base text-gray-400">Real-time overview of your listed projects</p>
                </div>
                <Button size="lg" className="bg-gradient w-fit px-4 text-[#0F1407]">
                    List new project
                </Button>
            </div>
            <div>
                <DataTableDemo />
            </div>
        </div>
    )
}

export default Projects
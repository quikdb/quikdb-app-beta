import {
    Card,
} from "@/components/ui/card"
// import {
//     Accordion,
//     AccordionContent,
//     AccordionItem,
//     AccordionTrigger,
// } from "@/components/ui/accordion"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Button } from "@/components/ui/button"
import { EllipsisVertical, PlusIcon, Search } from "lucide-react"
import { ProjectTable } from "./project-table"

const databases = [
    {
        id: 1,
        name: "UrbanLifeSuite",
        deadline: "12/12/2021",
        team: "Team 1",
    },
    {
        id: 2,
        name: "UrbanLifeSuite",
        deadline: "12/12/2021",
        team: "Team 1",
    },
    {
        id: 3,
        name: "UrbanLifeSuite",
        deadline: "12/12/2021",
        team: "Team 1",
    },
    {
        id: 4,
        name: "UrbanLifeSuite",
        deadline: "12/12/2021",
        team: "Team 1",
    },
]

const Groups = () => {
    return (
        <Card className="bg-[#151418] text-white border-[#242527] p-10 px-5 flex gap-10">
            <div className="flex flex-col gap-5 pr-10 border-r border-r-[#242527]">
                <Button className="bg-gradient w-fit px-4 text-[#0F1407]">
                    Create Database
                </Button>
                <div className="flex relative">
                    <Label className="absolute top-3 left-4 text-gray-400"><Search size={14} /></Label>
                    <Input placeholder="Search by DB name..." className="pl-10" />
                </div>

                {/* <Accordion type="single" collapsible className="w-full">
                    <AccordionItem value="item-1">
                        <AccordionTrigger className="flex gap-10">
                            <p className="text-base">database.name</p>
                            <EllipsisVertical size={16} className="text-gray-" />
                        </AccordionTrigger>
                        <AccordionContent>
                            Yes. It&apos;s animated by default, but you can disable it if you
                            prefer.
                        </AccordionContent>
                    </AccordionItem>
                </Accordion> */}

                {databases.map((database) => (
                    <div className="flex items-center gap-14">
                        <div className="flex gap-2">
                            <img src="/images/arrow-right.png" alt="arrow-right" />
                            <p className="text-base">{database.name}</p>
                        </div>
                        <EllipsisVertical size={16} className="text-gray-" />
                    </div>
                )
                )}
            </div>

            <div className="w-full">
                <div className="flex justify-between">
                    <div className="flex flex-col gap-1">
                        <p className="font-satoshi_medium text-xl">Organizations</p>
                        <p className="font-satoshi_light text-xs text-gray-400">Unlock API Access with Personal Tokens</p>
                    </div>
                    <Button variant="outline" className="font-satoshi_medium borde border-[#8A46FF]/60 px-4 w-fit text-gradient">
                        <PlusIcon className="text-gradient border border-[#8A46FF] border-dotted rounded-lg" />
                        Add Data Group
                    </Button>
                </div>
                <ProjectTable />
            </div>

        </Card>
    )
}

export default Groups
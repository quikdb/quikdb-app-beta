import {
    ChevronDown,
    GlobeIcon,
    User,
} from "lucide-react"

import { Button } from "@/components/ui/button"
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuLabel,
    DropdownMenuSeparator,
    DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"

const DashHeader = () => {
    return (
            <div className="flex justify-between pb-7 border-b border-b-[#1B1C1F]">
                <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                        <Button variant="outline" className="bg-transparent"><GlobeIcon /> Oluwatimileyin's Org <ChevronDown /></Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent className="w-56">
                        <DropdownMenuLabel>My Account</DropdownMenuLabel>
                        <DropdownMenuSeparator />
                        <DropdownMenuItem>
                            <User size={16} />
                            Profile
                        </DropdownMenuItem>
                    </DropdownMenuContent>
                </DropdownMenu>
                <div className="flex items-center gap-10 text-lg">
                    <div className="flex gap-2">
                        <img src="/images/gem.png" alt="gem" className="w-5" />
                        <p>30</p>
                    </div>
                    <div className="flex gap-3">
                        <img src="/images/user.png" alt="user" />
                        <p className="flex items-center">Oluwatimileyin <ChevronDown /></p>
                    </div>
                </div>

            </div>
    )
}

export default DashHeader
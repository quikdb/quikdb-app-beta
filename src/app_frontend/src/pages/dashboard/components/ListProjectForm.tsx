import { Button } from "@/components/ui/button"
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"

export default function ListProject() {
    return (
        <Dialog>
            <DialogTrigger asChild>
                <Button size="lg" className="bg-gradient w-fit px-4 text-[#0F1407]">
                    List new project
                </Button>
            </DialogTrigger>
            <DialogContent className="s:max-w-[425px] bg-[#111015] text-white border-[#242527] font-satoshi_regular">
                <DialogHeader>
                    <DialogTitle className="font-satoshi_medium">List Project</DialogTitle>
                    <DialogDescription>
                    Lorem Ipsum lorem ipsum lorem ipsum lorem ipsum
                    </DialogDescription>
                </DialogHeader>
                <hr className="border-gray-400" />
                <div className="grid gap-4 py-4">
                    <div className="grid gap-2">
                        <Label htmlFor="name">
                            Project Name
                        </Label>
                        <Input
                            id="name"
                            placeholder="Lisaprop"
                            className="col-span-3"
                        />
                    </div>
                    <div className="grid gap-2">
                        <Label htmlFor="username">
                            Deadline
                        </Label>
                        <Input
                            id="deadline"
                            placeholder="Lisaprop"
                            className="col-span-3"
                        />
                    </div>
                    <div className="grid gap-2">
                        <Label htmlFor="username">
                            Team
                        </Label>
                        <Input
                            id="team"
                            placeholder="Lisaprop"
                            className="col-span-3"
                        />
                    </div>
                </div>
                <DialogFooter className="sm:justify-start">
                    <Button className="bg-gradient w-fit px-4 text-[#0F1407]">
                        List new project
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    )
}
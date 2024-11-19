import DashHeader from "@/components/DashHeader";
import { Button } from "@/components/ui/button";
import { PlusIcon } from "lucide-react";

const Organizations = () => {

    return (
        <div className="max-md:mt-5 mb-10 p-10 min-h-screen">
            <DashHeader />
            <div className="mt-10">
                <p className="text-xl">Welcome Oluwatimileyin 👋</p>
                <div className="flex flex-col justify-center items-center gap-10 h-[50vh]">
                    <div className="flex flex-col items-center">
                        <img src="/images/empty_box.png" alt="empty_box" />
                        <p className="text-sm font-light text-gray-600">No Project Available . Create a new project to get stated</p>
                    </div>
                    <Button className="bg-gradient w-fit text-[#0F1407]">
                        <PlusIcon className="text-white border border-dotted rounded-lg" />
                        New Project
                    </Button>
                </div>
            </div>
        </div>
    );
};

export default Organizations;
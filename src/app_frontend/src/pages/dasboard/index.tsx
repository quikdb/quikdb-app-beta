import DashHeader from "@/components/DashHeader";
import Sidebar from "@/components/Sidebar";
import { Outlet } from "react-router-dom";

const Dash = () => {
    return (
        <div className="max-md:px-4 max-md:py-3 min-h-screen">
            <Sidebar />
            <div className="ml-[20%] max-lg:m-0">
                <div className="max-md:mt-5 mb-10 p-10 bg-transparent min-h-screen">
                    <DashHeader />
                    <Outlet />
                </div>
            </div>
        </div>
    );
};

export default Dash;
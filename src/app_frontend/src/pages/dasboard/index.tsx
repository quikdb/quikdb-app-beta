import Sidebar from "@/components/Sidebar";
import { Outlet } from "react-router-dom";

const Dash = () => {
  return (
    <div className="max-md:px-4 max-md:py-3 min-h-screen">
      <Sidebar />
      <div className="ml-[20%] max-lg:m-0">
        <Outlet />
      </div>
    </div>
  );
};

export default Dash;
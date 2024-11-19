import { Link } from 'react-router-dom';
import { Button } from './ui/button';
import { BellIcon, DashboardIcon, FileIcon, PersonIcon } from '@radix-ui/react-icons';
import { HeadphonesIcon, LogOutIcon } from 'lucide-react';

const Sidebar = () => {

    const navigation = [
        { name: 'Overview', to: '', icon: <DashboardIcon /> },
        { name: 'Projects', to: 'new-record', icon: <FileIcon /> },
        { name: 'Organizations', to: 'manage-staff', icon: <PersonIcon /> },
        { name: 'Notifications', to: 'notifications', icon: <BellIcon /> },
    ].filter(Boolean);

    return (
        <div className='bg-blackoff w-[17%] border-r-2 border-r-[#1B1C1F] fixed hidden lg:flex flex-col items-center justify-start p-10 py-20 min-h-screen h-full'>
            <div className="flex flex-col justify-between h-full">
                <div>
                    <div className="text-gradient text-xl pl-10">quikDB</div>
                    <div className='flex flex-col gap-8 mt-20'>
                        {navigation.map((item) => {
                            // console.log(item.to);
                            return (
                                <Link
                                    key={item.name}
                                    to={item.to}
                                    className={`flex items-center gap-3 rounded-lg py-2 px-8 text-base leading-7
                                ${location.pathname === `dashboard/${item.to}` ? 'bg-blue-800' : 'hover:bg-blue-800'}`}
                                >
                                    {item.icon}
                                    {item.name}
                                </Link>
                            )
                        })}
                    </div>
                </div>
                <div className="py-6 mt-20 flex flex-col">
                    <Link to="/"><Button size="lg" className="mt-5 font-clash_semibold"><HeadphonesIcon /> Support</Button></Link>
                    <Link to="/"><Button size="lg" className="mt-5 font-clash_semibold"><LogOutIcon /> Logout</Button></Link>
                </div>
            </div>
        </div>
    );
};

export default Sidebar
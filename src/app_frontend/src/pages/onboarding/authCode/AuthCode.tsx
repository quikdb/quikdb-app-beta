import { FormHeader, Input } from "@/components/onboarding";
import { Button } from "@/components/ui/button";
import { Form } from "react-router-dom";
import React from "react";


interface AuthCodeProps {
  email?: string
}

const AuthCode:React.FC<AuthCodeProps> = ({email}) => {
  return (
    <div className='flex flex-col w-full p-10'>
    <FormHeader title='Create an account' description={`One-time login code sent to ${email}.`} showLogo />

    <main className='flex flex-col items-center justify-center my-16 w-full'>
      <div className='flex flex-col w-full md:w-[680px] items-center'>
        <Form action="submit" className='flex flex-col gap-y-4 items-center w-full'>
          <Input type='text'
            placeholder='Enter Code'
            required
          />

          <Button type='submit' className='w-full bg-[#141414] h-[50px] text-lg rounded-2xl p-6 text-[#A5A5A5]'>Continue</Button>

          <span className='text-[16px] text-gradient cursor-pointer'>Resend code</span>
        </Form>
      </div>
    </main>
  </div>
  )
}

export default AuthCode;
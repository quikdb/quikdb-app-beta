import { FormHeader, Input } from "@/components/onboarding"
import { Button } from "@/components/ui/button"
import { useState } from "react"
import { Form } from "react-router-dom"

const ForgotPassword = () => {

  const [emailAddress, setEmailAddress] = useState("");

  return (
    <div className='flex flex-col w-full max-w-screen-2xl p-10'>
    <FormHeader title='Forgot password' description={`Please enter the email assigned to your account for password recovery.`} showLogo />

    <main className='flex flex-col items-center justify-center my-16 w-full'>
      <div className='flex flex-col w-full md:w-[680px] items-center'>
        <Form action="submit" className='flex flex-col gap-y-4 items-center w-full'>
          <Input type='email'
            placeholder='Enter Address'
            labelTitle="Email Address"
            onChange={(e) => {setEmailAddress(e.target.value)}}
            value={emailAddress}
            required
          />

          <Button type='submit' className={`w-full ${emailAddress !== "" ? "bg-white text-[#141414] hover:text-black hover:bg-[#dadada]" : "bg-[#141414] text-[#A5A5A5]"}  h-[50px] text-lg rounded-2xl p-6`}>Send Code</Button>

          <span className='text-[16px] text-gradient cursor-pointer'>Resend code</span>
        </Form>
      </div>
    </main>
  </div>
  )
}

export default ForgotPassword
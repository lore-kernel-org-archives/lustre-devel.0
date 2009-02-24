From: di wang <di.wang@sun.com>
Date: Mon, 23 Feb 2009 20:04:05 -0500
Subject: [Lustre-devel] moving obd_fail_check to libcfs
In-Reply-To: <49A336FB.1040908@cray.com>
References: <49A18841.7030200@cray.com>
	<56B06EF4-AAF5-448C-96C0-55E5E9A1AA44@sun.com>
	<010b01c995ff$43083420$c9189c60$@com> <49A32851.50803@sun.com>
	<49A336FB.1040908@cray.com>
Message-ID: <49A34785.5020007@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

Nicholas Henke wrote:
>
> Is there a branch name I could checkout to look at this ? I'd like to 
> make sure the fail_loc move would be easy to tie into that.
It is in the b_hd_params, and you can also check bug 15384.

Thanks
WangDi
>> The only difference for those sysctl parameters is that you may not 
>> use /etc/sysctl.conf to control them anymore, and lctl set_param is 
>> the only interface here.
>>
>> Actually, you can also move this now. but it means you need move 
>> those obd proc api to libcfs layer,  which  might  not  be  small  
>> amount  of  work.
>
> It isn't too bad - they use the CFS_PROC_PROTO and not all of the 
> lprocfs_XXX() functionality.
>
> It should like this would have a limited lifetime in 1.6.X and 1.8.X, 
> but I'm fine with that. That gives us a bit of time :-)
>
> Nic
>

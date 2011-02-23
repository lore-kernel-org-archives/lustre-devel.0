From: wangdi <di.wang@whamcloud.com>
Date: Wed, 23 Feb 2011 11:02:08 -0800
Subject: [Lustre-devel] problem with CMD
In-Reply-To: <8CDA124706596DF-23EC-3368C@webmail-d045.sysops.aol.com>
References: <8CDA124706596DF-23EC-3368C@webmail-d045.sysops.aol.com>
Message-ID: <4D6559B0.1040503@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 02/22/2011 07:54 PM, Ravi wrote:
>
>
> Hello  All
>
> I have been working on lustre for 3-4 months and now want to move 
> CMD(clustered meta data).i am using lustre-2.0.0.I was not able to 
>  get any links or documents which  could help me install it.I  came 
> across some documents one which  asked me to format the one MDT(drive) 
> and mount it on 2 MDS and the MDS takes care of notifying the 
> client.Another document said i should format 2 (separate )drives as 
> MDT and then mount it on the 2 MDS.Also i read that CMD has a master 
> MDS and Slave MDS.Do we have to configure it differently ? Also i 
> could get some rpms for patched kernel from lustre download site 
> for lustre-ldiskfs-3.2.0-2.6.18_164.11.1.el5_lustre.2.0.0.1.x86_64.rpm
> lustre-modules-2.0.0.1-2.6.18_164.11.1.el5_lustre.2.0.0.1.x86_64.rpm, kernel-2.6.18-164.11.1.el5_lustre.2.0.0.1.x86_64.rpm.But 
> i am not sure if i can use the same patched kernel i was using for 
> Single MDS setup. I am not exactly able to figure out how this should 
> be done.Any help would be appreciated.Thanks
CMD is not supported in lustre-2.0.0.

Thanks
WangDi
>
>
>
> Raviprakash Darbha
>
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20110223/f4671397/attachment.htm>

From: Peter Jones <pjones@whamcloud.com>
Date: Mon, 28 Feb 2011 09:31:02 -0800
Subject: [Lustre-devel] problem with CMD
In-Reply-To: <8CDA57DF73AD243-2060-146E8@angweb-usd022.sysops.aol.com>
References: <8CDA124706596DF-23EC-3368C@webmail-d045.sysops.aol.com><4D6559B0.1040503@whamcloud.com><8CDA453BDAF3CCD-1BB0-24B96@webmail-d139.sysops.aol.com><AANLkTik3fH85X8kxc=9PCWm-UJdKmt4L2wW9CrqJjzQv@mail.gmail.com>	<8CDA57D917C4CC9-2060-145E7@angweb-usd022.sysops.aol.com>
	<8CDA57DF73AD243-2060-146E8@angweb-usd022.sysops.aol.com>
Message-ID: <4D6BDBD6.30602@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Ravi

No, Lustre does not presently support CMD. It is planned for a future 
(as yet TBD)
2.x release

Regards

Peter

On 11-02-28 8:44 AM, Ravi wrote:
> Sry  the link is
> http://wiki.lustre.org/index.php/Clustered_Metadata
>
>
>
> -----Original Message-----
> From: Ravi <raviprakashdrbh@aol.com>
> To: tsrjzq <tsrjzq@gmail.com>; Lustre-devel 
> <Lustre-devel@lists.lustre.org>
> Sent: Mon, Feb 28, 2011 6:42 am
> Subject: Re: [Lustre-devel] problem with CMD
>
> Hey
> I found some info abt CMD on lustre site .Could anyone please comment 
> on this ..
>
> Thanks
>
>
>
> -----Original Message-----
> From: Larry <tsrjzq at gmail.com <mailto:tsrjzq@gmail.com>>
> To: Ravi <raviprakashdrbh at aol.com <mailto:raviprakashdrbh@aol.com>>
> Sent: Sun, Feb 27, 2011 6:26 pm
> Subject: Re: [Lustre-devel] problem with CMD
>
> seems that none of lustre supports CMD
>
> 2011/2/27 Ravi<raviprakashdrbh at aol.com  <mailto:raviprakashdrbh@aol.com>>:
> >  Hey
> >  Thanks for the reply.I want to confirm if any  lustre is actually supporting
> >  CMD ??Could you pls provide me some links  if there are any  ??Thanks ..
> >
> >
> >
> >  -----Original Message-----
> >  From: wangdi<di.wang at whamcloud.com  <mailto:di.wang@whamcloud.com>>
> >  To: lustre-devel<lustre-devel at lists.lustre.org  <mailto:lustre-devel@lists.lustre.org>>
> >  Sent: Wed, Feb 23, 2011 1:16 pm
> >  Subject: Re: [Lustre-devel] problem with CMD
> >
> >  On 02/22/2011 07:54 PM, Ravi wrote:
> >
> >  Hello  All
> >  I have been working on lustre for 3-4 months and now want to move
> >  CMD(clustered meta data).i am using lustre-2.0.0.I was not able to  get any
> >  links or documents which  could help me install it.I  came across some
> >  documents one which  asked me to format the one MDT(drive) and mount it on 2
> >  MDS and the MDS takes care of notifying the client.Another document said i
> >  should format 2 (separate )drives as MDT and then mount it on the 2 MDS.Also
> >  i read that CMD has a master MDS and Slave MDS.Do we have to configure it
> >  differently ? Also i could get some rpms for patched kernel from lustre
> >  download site
> >  for lustre-ldiskfs-3.2.0-2.6.18_164.11.1.el5_lustre.2.0.0.1.x86_64.rpm
> >  lustre-modules-2.0.0.1-2.6.18_164.11.1.el5_lustre.2.0.0.1.x86_64.rpm, kernel-2.6.18-164.11.1.el5_lustre.2.0.0.1.x86_64.rpm.But
> >  i am not sure if i can use the same patched kernel i was using for Single
> >  MDS setup. I am not exactly able to figure out how this should be done.Any
> >  help would be appreciated.Thanks
> >
> >  CMD is not supported in lustre-2.0.0.
> >
> >  Thanks
> >  WangDi
> >
> >
> >
> >  Raviprakash Darbha
> >
> >  _______________________________________________
> >  Lustre-devel mailing list
> >  Lustre-devel at lists.lustre.org  <mailto:Lustre-devel@lists.lustre.org>
> >  http://lists.lustre.org/mailman/listinfo/lustre-devel
> >
> >  _______________________________________________
> >  Lustre-devel mailing list
> >  Lustre-devel at lists.lustre.org  <mailto:Lustre-devel@lists.lustre.org>
> >  http://lists.lustre.org/mailman/listinfo/lustre-devel
> >
> >
> >  _______________________________________________
> >  Lustre-devel mailing list
> >  Lustre-devel at lists.lustre.org  <mailto:Lustre-devel@lists.lustre.org>
> >  http://lists.lustre.org/mailman/listinfo/lustre-devel
> >
> >
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org  <mailto:Lustre-devel@lists.lustre.org>
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel

-- 
Peter Jones
Whamcloud, Inc.
www.whamcloud.com

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20110228/bb97b4e5/attachment.htm>

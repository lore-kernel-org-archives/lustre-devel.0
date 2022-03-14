Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 84168C433EF
	for <lustre-devel@archiver.kernel.org>; Mon, 14 Mar 2022 01:41:52 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2FC38216162;
	Sun, 13 Mar 2022 18:41:51 -0700 (PDT)
Received: from mail-oo1-f46.google.com (mail-oo1-f46.google.com
 [209.85.161.46])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 229BD205734
 for <lustre-devel@lists.lustre.org>; Sun, 13 Mar 2022 18:41:49 -0700 (PDT)
Received: by mail-oo1-f46.google.com with SMTP id
 h16-20020a4a6f10000000b00320507b9ccfso18388284ooc.7
 for <lustre-devel@lists.lustre.org>; Sun, 13 Mar 2022 18:41:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linaro.org; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=VRtCblab5ZNi2Q1Bieb/4xTntA9Idp+gkGYN6GHFDEs=;
 b=dQc4WStc51gZjtjlR0ooL7i/5KOf9ELWvLV0OmDbN0tHzpumKY4WzfV8YDq6rnMM4q
 bf+cQ9sUsxoWZXs8hIEI+7lv59XKl5QnVPEwrGWZkmEDQ5Ua2Q4oPr3becG5WhB5U3JK
 Xpw9ECRAI52Fl/M37EynpbLshc3zE9YwH3bFNctyzTxdrZTEHg7EqI6ch2c91Kd5UXpf
 53aKBledF1MmuqD0EzNM4HlpOW47Yj3xGYx9alULN+4klF69po+AvdgoZKaGQJpz6HVl
 b+TXl1jkkxT5Xt5N1OtFkTm4nDfxkYZKnWEFTzYYGXnTLM57ZH3pY3qk5XsMma/cA9OI
 takw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20210112;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=VRtCblab5ZNi2Q1Bieb/4xTntA9Idp+gkGYN6GHFDEs=;
 b=rSzRPh4AyQNyb0IQ3Q80HjB9rLatuscnszz4Inj6uQI6d8d9OPw/4AoFmM/K9PKKT4
 Zko5M6rChsXo/3Z/9+q6DZ3BamqDlj+7uEbxxG5GjWInlD6X04JJuZSVVC+SxReDPNsn
 dNVJ/BmabLhWV0N3ZsrIF/383e6+EXBIWQcXifNnGfiSBgKtwk+NCdvs1UgPXs/8G8Vb
 bhaFwTpvO9Yo7/ZmVC4gV9eRojDCH8vBzrzuK8eIIpK9goyAnECxF92W5Sq5mOLPfT2h
 IeLhwcuO9a87tVASOKnZzJNL9NhyFNczBWtsuxjb49IJTZANP8dFRdyh6BT9ajxM1cQc
 RVBQ==
X-Gm-Message-State: AOAM531jFC2IswjRDmNbFlBq0mYoitn1LQvzSvgMs0HH9wekU+Pgl5K2
 6wgc+ZC1Is+VWC7AoahaCVlW9Vz5PLuemR+Jdo/y
X-Google-Smtp-Source: ABdhPJylkNgxOYuaVwp6ZsXaIpVClgXzAcJNTs5Fxq2lMmPB+7R9qVWPt0JzhLb0GkG7pPznrh99kBc9x0y0YJmaADc=
X-Received: by 2002:a05:6870:630c:b0:da:b3f:324d with SMTP id
 s12-20020a056870630c00b000da0b3f324dmr10495461oao.253.1647222108215; Sun, 13
 Mar 2022 18:41:48 -0700 (PDT)
MIME-Version: 1.0
References: <CACzn6-UFqbF+rb1wvDJQ=6+jrHDsEZUufa8AG6vY5izH+KNNVg@mail.gmail.com>
 <C7B35B3E-0002-41B3-A653-46966DE7E15C@ddn.com>
In-Reply-To: <C7B35B3E-0002-41B3-A653-46966DE7E15C@ddn.com>
Date: Mon, 14 Mar 2022 09:41:37 +0800
Message-ID: <CACzn6-W-BWmDqb_JSAErZrEx=tOJqnMW5Q+9syZ0DCO-eTTRbg@mail.gmail.com>
To: Andreas Dilger <adilger@whamcloud.com>
Subject: Re: [lustre-devel] lustre:pcc: Sanity-pcc 7a test hang(Both on
 Aarch64 and X86_64) discussion
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
From: Kevin Zhao via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Kevin Zhao <kevin.zhao@linaro.org>
Cc: Li Xi <lixi@ddn.com>, Lustre-devel <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============8561135747316746595=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============8561135747316746595==
Content-Type: multipart/alternative; boundary="000000000000a06b5405da23c8fc"

--000000000000a06b5405da23c8fc
Content-Type: text/plain; charset="UTF-8"

Hi  Andreas,

Great! Thanks for that info, will take a look at that.

On Sat, 12 Mar 2022 at 08:02, Andreas Dilger <adilger@whamcloud.com> wrote:

> Kevin,
> Qian  has a patch https://review.whamcloud.com/40092 "LU-14003
> <https://jira.whamcloud.com/browse/LU-14003> pcc: rework PCC mmap
> implementation" that is changing the PCC MMAP code significantly, but is
> waiting for the 2.16.0 feature landing window to open.  It needs to be
> refreshed, but it would be helpful if you could take a look through that
> patch to see if it would resolve the issue you are seeing.
>
> On Mar 11, 2022, at 01:18, Kevin Zhao via lustre-devel <
> lustre-devel@lists.lustre.org> wrote:
>
> Hi,
>
> Recently we've worked on the bug
> https://jira.whamcloud.com/browse/LU-14346. This bug will make the *mmap
> write* hang forever. This one is first occurring on Aarch64, but if we do
> a small change
> <https://github.com/kevinzs2048/devbox/blob/master/notes/lustre/pcc_sanity-pcc-7a-analysis.md#reproduced-on-x86_64-with-a-small-change>,
> we *can easily reproduce it on X86_64*. For more details analysis of this
> bug, you can also check the link
> <https://github.com/kevinzs2048/devbox/blob/master/notes/lustre/pcc_sanity-pcc-7a-analysis.md>
> .
>
> The hang location is here
> <https://github.com/lustre/lustre-release/blob/master/lustre/tests/multiop.c#L725> as
> below:
> ==============
>     case 'W':
>         for (i = 0; i < mmap_len && mmap_ptr; i += 4096)
>             mmap_ptr[i] += junk++;
>         break;
> ===============
>
> *Bug Analysis - different behavior when run **mmap_ptr[i] += junk++ on
> different platform.*
> Traditionally, this process is:
> 1. read from mmap_ptr[i]first(Execute the read page fault)
> 2. Write a value to the same page(execute the page_mkwrite to change the
> page to writable).
>
> But on different platforms, it executes quite differently.
> On aarch64 platform: do_page_fault, no FAULT_FLAG_WRITE set, so
> handle_pte_fault will call do_read_fault
>
>    - do_read_fault:
>                __do_fault -> call ll_fault, get a page from pcc_fault
>                finish_fault(map the returned page to page tables)
>                unlock_page
>                vmf->flags is VM_FAULT_LOCKED
>    - call do_wp_page --> do_page_mkwrite --> ll_page_mkwrite
>
> On X86_64 platform, the mechanism is different. On X86_64, do_page_fault,
> with * FAULT_FLAG_WRITE set*, so handle_pte_fault will call
> *do_shared_fault*.
>
>    - do_shared_fault
>       -  __do_fault -> call ll_fault, get a page from pcc_fault
>       - do_page_mkwrite-> call ll_page_mkwrite
>       - finish_fault(map the returned page to page tables)
>       - fault_dirty_shared_page
>
> *Bug Analysis: why hang forever:*
> Also can check:
> https://github.com/kevinzs2048/devbox/blob/master/notes/lustre/pcc_sanity-pcc-7a-analysis.md#kernel-do_page_fault-process-analysis
> for more details.
>
> do_page_mkwrite--->ll_page_mkwrite.
>     Insert the issue 0x1412 OBD_FAIL_LLITE_PCC_DETACH_MKWRITE.
>     Return with VM_FAULT_RETRY | VM_FAULT_NOPAGE
>     RETRY again, due to PTE is not NULL, vmf->flags FAULT_FLAG_WRITE, will
> call do_wp_page again.
> So that next time we will enter into do_page_mkwrite again. hanging
> forever.
>
> *Seek a good solution*
> As the above code snippet shows, *we want to let the kernel retry the
> mmap write (->fault() and ->page_mkwrite).*
> In handle_pte_fault, if there is no page or the page is not mapped(no PTE
> found), then
>  __do_page_fault will try the memory fault handling.
>
> The easy fix here is to* remove the page and page table entry when we do
> fail injection in pcc_page_mkwrite.* But I don't find a good method to
> execute this, so list the info here and ask for community help.
>
> Some tried fix is:
> add function: *generic_error_remove_page*, but the mapped page still can
> not be unmapped successfully. The error log is here
> <https://github.com/kevinzs2048/devbox/blob/master/notes/lustre/pcc_sanity-pcc-7a-analysis.md#solution>
> .
>
> Since I'm a newbie to Lustre and not quite familiar with the memory
> management process, so please give some advice on this bug fix. Thanks in
> advance.
>
>
> Cheers, Andreas
> --
> Andreas Dilger
> Lustre Principal Architect
> Whamcloud
>
>
>
>
>
>
>
>

-- 
*Best Regards*

*Kevin Zhao*

Tech Lead, LDCG Cloud Infrastructure

Linaro Vertical Technologies

IRC(freenode): kevinz

Slack(kubernetes.slack.com): kevinz

kevin.zhao@linaro.org | Mobile/Direct/Wechat:  +86 18818270915

--000000000000a06b5405da23c8fc
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi=C2=A0 Andreas,<div><br></div><div>Great! Thanks for tha=
t info, will take a look at that.</div></div><br><div class=3D"gmail_quote"=
><div dir=3D"ltr" class=3D"gmail_attr">On Sat, 12 Mar 2022 at 08:02, Andrea=
s Dilger &lt;<a href=3D"mailto:adilger@whamcloud.com">adilger@whamcloud.com=
</a>&gt; wrote:<br></div><blockquote class=3D"gmail_quote" style=3D"margin:=
0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">



<div style=3D"overflow-wrap: break-word;">
Kevin,=C2=A0
<div>Qian =C2=A0has a patch=C2=A0<a href=3D"https://review.whamcloud.com/40=
092" target=3D"_blank">https://review.whamcloud.com/40092</a> &quot;<a href=
=3D"https://jira.whamcloud.com/browse/LU-14003" target=3D"_blank">LU-14003<=
/a> pcc: rework PCC mmap implementation&quot; that is changing the
 PCC MMAP code significantly, but is waiting for the 2.16.0 feature landing=
 window to open.=C2=A0 It needs to be refreshed, but it would be helpful if=
 you could take a look through that patch to see if it would resolve the is=
sue you are seeing.<br>
<div><br>
<blockquote type=3D"cite">
<div>On Mar 11, 2022, at 01:18, Kevin Zhao via lustre-devel &lt;<a href=3D"=
mailto:lustre-devel@lists.lustre.org" target=3D"_blank">lustre-devel@lists.=
lustre.org</a>&gt; wrote:</div>
<br>
<div>
<div dir=3D"ltr">Hi,
<div><br>
</div>
<div>Recently we&#39;ve worked on the bug=C2=A0<a href=3D"https://jira.wham=
cloud.com/browse/LU-14346" target=3D"_blank">https://jira.whamcloud.com/bro=
wse/LU-14346</a>. This bug will make the
<b>mmap write</b> hang forever. This one is first occurring on Aarch64, but=
 if we do a
<a href=3D"https://github.com/kevinzs2048/devbox/blob/master/notes/lustre/p=
cc_sanity-pcc-7a-analysis.md#reproduced-on-x86_64-with-a-small-change" targ=
et=3D"_blank">
small change</a>, we <b>can easily reproduce it on X86_64</b>. For more det=
ails=C2=A0analysis of this bug, you can also<a href=3D"https://github.com/k=
evinzs2048/devbox/blob/master/notes/lustre/pcc_sanity-pcc-7a-analysis.md" t=
arget=3D"_blank"> check the link</a>.</div>
<div><br>
</div>
<div>The <a href=3D"https://github.com/lustre/lustre-release/blob/master/lu=
stre/tests/multiop.c#L725" target=3D"_blank">
hang location is here</a>=C2=A0as below:<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
=C2=A0 =C2=A0 case &#39;W&#39;:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i &lt; mmap_len &amp;&amp; mmap_p=
tr; i +=3D 4096)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mmap_ptr[i] +=3D junk++;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 break;<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D</div>
<div><br>
</div>
<div><b>Bug Analysis - different behavior when run=C2=A0</b><b>mmap_ptr[i] =
+=3D junk++ on different platform.</b></div>
<div>Traditionally, this process is:<br>
1. read from mmap_ptr[i]first(Execute the read page fault)<br>
2. Write a value to the same page(execute the page_mkwrite to change the pa=
ge to writable).<br>
<br>
But on different platforms, it executes quite differently.<br>
On aarch64 platform: do_page_fault, no FAULT_FLAG_WRITE set, so handle_pte_=
fault will call do_read_fault
<ul>
<li>do_read_fault:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __do_fault=C2=A0-&gt; call ll_fau=
lt, get a page from pcc_fault<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 finish_fault(map the returned pag=
e to page tables)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unlock_page<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 vmf-&gt;flags is VM_FAULT_LOCKED<=
/li><li>call do_wp_page --&gt; do_page_mkwrite --&gt; ll_page_mkwrite</li><=
/ul>
On X86_64 platform, the mechanism is different. On X86_64, do_page_fault, w=
ith <b>
FAULT_FLAG_WRITE set</b>, so handle_pte_fault will call <b>do_shared_fault<=
/b>.
<ul>
<li>do_shared_fault</li><ul>
<li>=C2=A0__do_fault -&gt; call ll_fault, get a page from pcc_fault</li><li=
>do_page_mkwrite-&gt; call ll_page_mkwrite</li><li>finish_fault(map the ret=
urned page to page tables)</li><li>fault_dirty_shared_page</li></ul>
</ul>
</div>
<div><b>Bug Analysis: why hang forever:</b></div>
<div>Also can check:=C2=A0<a href=3D"https://github.com/kevinzs2048/devbox/=
blob/master/notes/lustre/pcc_sanity-pcc-7a-analysis.md#kernel-do_page_fault=
-process-analysis" target=3D"_blank">https://github.com/kevinzs2048/devbox/=
blob/master/notes/lustre/pcc_sanity-pcc-7a-analysis.md#kernel-do_page_fault=
-process-analysis</a>
 for more details.</div>
<div><br>
</div>
<div>do_page_mkwrite---&gt;ll_page_mkwrite.<br>
=C2=A0 =C2=A0 Insert the issue 0x1412 OBD_FAIL_LLITE_PCC_DETACH_MKWRITE.<br=
>
=C2=A0 =C2=A0 Return with VM_FAULT_RETRY | VM_FAULT_NOPAGE<br>
=C2=A0 =C2=A0 RETRY again, due to PTE is not NULL, vmf-&gt;flags FAULT_FLAG=
_WRITE, will call do_wp_page again.<br>
So that next time we will enter into do_page_mkwrite again. hanging forever=
.<br>
</div>
<div><br>
</div>
<div><b>Seek a good solution</b></div>
As the above code snippet shows, <b>we want to let the kernel retry=C2=A0th=
e mmap write (-&gt;fault() and -&gt;page_mkwrite).</b><br>
In handle_pte_fault, if there is no page or the page is not mapped(no PTE f=
ound), then<br>
=C2=A0__do_page_fault will try the memory fault handling. <br>
<br>
The easy fix here is to<b> remove the page and page table entry when we do =
fail injection in pcc_page_mkwrite.</b> But I don&#39;t find a good method =
to execute this, so list the info here and ask for community help.<br>
<br>
Some tried fix is:<br>
<div>add function: <b>generic_error_remove_page</b>, but the mapped page st=
ill can not be unmapped successfully.
<a href=3D"https://github.com/kevinzs2048/devbox/blob/master/notes/lustre/p=
cc_sanity-pcc-7a-analysis.md#solution" target=3D"_blank">
The error log is here</a>.<br>
</div>
<div><br>
</div>
<div>Since I&#39;m a newbie to Lustre and not quite familiar with the memor=
y management process, so please=C2=A0give some advice on this bug fix. Than=
ks in advance.</div>
</div>
</div>
</blockquote>
</div>
<br>
<div>
<div dir=3D"auto" style=3D"color:rgb(0,0,0);letter-spacing:normal;text-alig=
n:start;text-indent:0px;text-transform:none;white-space:normal;word-spacing=
:0px;text-decoration:none">
<div dir=3D"auto" style=3D"color:rgb(0,0,0);letter-spacing:normal;text-alig=
n:start;text-indent:0px;text-transform:none;white-space:normal;word-spacing=
:0px;text-decoration:none">
<div dir=3D"auto" style=3D"color:rgb(0,0,0);letter-spacing:normal;text-alig=
n:start;text-indent:0px;text-transform:none;white-space:normal;word-spacing=
:0px;text-decoration:none">
<div dir=3D"auto" style=3D"color:rgb(0,0,0);letter-spacing:normal;text-alig=
n:start;text-indent:0px;text-transform:none;white-space:normal;word-spacing=
:0px;text-decoration:none">
<div dir=3D"auto" style=3D"color:rgb(0,0,0);letter-spacing:normal;text-alig=
n:start;text-indent:0px;text-transform:none;white-space:normal;word-spacing=
:0px;text-decoration:none">
<div dir=3D"auto" style=3D"color:rgb(0,0,0);letter-spacing:normal;text-alig=
n:start;text-indent:0px;text-transform:none;white-space:normal;word-spacing=
:0px;text-decoration:none">
<div>Cheers, Andreas</div>
<div>--</div>
<div>Andreas Dilger</div>
<div>Lustre=C2=A0Principal Architect</div>
<div>Whamcloud</div>
<div><br>
</div>
<div><br>
</div>
<div><br>
</div>
</div>
</div>
</div>
</div>
</div>
<br>
</div>
<br>
<br>
</div>
<br>
</div>
</div>

</blockquote></div><br clear=3D"all"><div><br></div>-- <br><div dir=3D"ltr"=
 class=3D"gmail_signature"><div dir=3D"ltr"><div><div dir=3D"ltr"><div><div=
 dir=3D"ltr"><div dir=3D"ltr"><b>Best Regards</b><div><div style=3D"margin:=
0px;padding:0px 0px 20px;width:1262px"><div><div style=3D"margin:8px 0px 0p=
x;padding:0px"><div><div dir=3D"ltr"><font><div dir=3D"ltr"><div dir=3D"ltr=
"><p class=3D"MsoNormal" style=3D"color:rgb(136,136,136);font-family:Roboto=
,RobotoDraft,Helvetica,Arial,sans-serif;font-size:medium"><b><span style=3D=
"font-size:11pt"><font color=3D"#38761d">Kevin Zhao</font></span></b></p><p=
 class=3D"MsoNormal" style=3D"color:rgb(136,136,136);font-family:Roboto,Rob=
otoDraft,Helvetica,Arial,sans-serif;font-size:medium"><font color=3D"#757b8=
0"><span style=3D"font-size:14.6667px">Tech Lead, LDCG Cloud Infrastructure=
</span></font></p><p class=3D"MsoNormal" style=3D"color:rgb(136,136,136);fo=
nt-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-size:medium"><=
font color=3D"#757b80"><span style=3D"font-size:14.6667px">Linaro Vertical =
Technologies</span></font></p><p class=3D"MsoNormal" style=3D"color:rgb(136=
,136,136);font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-si=
ze:medium"><font color=3D"#757b80"><span style=3D"font-size:14.6667px">IRC(=
freenode): kevinz</span></font></p><p class=3D"MsoNormal"><font color=3D"#7=
57b80"><font color=3D"#888888" face=3D"Roboto, RobotoDraft, Helvetica, Aria=
l, sans-serif"><span style=3D"font-size:14.6667px">Slack(</span></font><fon=
t face=3D"Roboto, RobotoDraft, Helvetica, Arial, sans-serif"><span style=3D=
"font-size:14.6667px"><a href=3D"http://kubernetes.slack.com" target=3D"_bl=
ank">kubernetes.slack.com</a>)</span></font><font color=3D"#888888" face=3D=
"Roboto, RobotoDraft, Helvetica, Arial, sans-serif"><span style=3D"font-siz=
e:14.6667px">: kevinz</span></font></font></p><p class=3D"MsoNormal" style=
=3D"color:rgb(136,136,136);font-family:Roboto,RobotoDraft,Helvetica,Arial,s=
ans-serif;font-size:medium"><font color=3D"#757b80"><span style=3D"font-siz=
e:14.6667px"><a href=3D"mailto:kevin.zhao@linaro.org" target=3D"_blank"><sp=
an>kevin.zhao@linaro.org</span></a>=C2=A0| Mobile/Direct/Wechat:=C2=A0 +86 =
18818270915</span></font><span style=3D"color:rgb(117,123,128);font-size:11=
pt">=C2=A0</span><br></p><div style=3D"color:rgb(136,136,136);font-family:R=
oboto,RobotoDraft,Helvetica,Arial,sans-serif;font-size:medium"><span style=
=3D"color:rgb(117,123,128);font-size:11pt"><br></span></div></div></div></f=
ont></div><div style=3D"font-family:Roboto,RobotoDraft,Helvetica,Arial,sans=
-serif;font-size:medium"></div></div></div><div style=3D"font-family:Roboto=
,RobotoDraft,Helvetica,Arial,sans-serif;font-size:medium"></div></div></div=
></div></div></div></div></div></div></div></div>

--000000000000a06b5405da23c8fc--

--===============8561135747316746595==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============8561135747316746595==--

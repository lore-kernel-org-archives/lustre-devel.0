Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 6A095C433EF
	for <lustre-devel@archiver.kernel.org>; Fri, 11 Mar 2022 08:18:58 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B540821C906;
	Fri, 11 Mar 2022 00:18:56 -0800 (PST)
Received: from mail-oi1-f179.google.com (mail-oi1-f179.google.com
 [209.85.167.179])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D0E3021C8EE
 for <lustre-devel@lists.lustre.org>; Fri, 11 Mar 2022 00:18:54 -0800 (PST)
Received: by mail-oi1-f179.google.com with SMTP id j83so8589861oih.6
 for <lustre-devel@lists.lustre.org>; Fri, 11 Mar 2022 00:18:54 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linaro.org; s=google;
 h=mime-version:from:date:message-id:subject:to:cc;
 bh=Jh6TD3HOJt6eAs1GuzJx9rq4K7ChpMIGA88NJ5qJr70=;
 b=S2hZD0S+rY8arpF8ms4PtbazMoasAEKchQDlyAAxlw7vK3N2oLgDpcil90xgtiAUlK
 LR9eLmp6aKMHW7QKuOB+87RKAu2g+eb7iUu5+SOYJyasmjwBt9QVfY6bwZiHKZ02uZqR
 Lc0jVdao2zaXo2AcIEKyBqyRwItwxtD7UASMO1FJNuLEVHUrRSIMA4aS8UcSXdzB/CXb
 kzcmGdRxK2OwGtUMAAaRlLxfZvfHYiGOP6jE0D6uRL5eIiW39dLVsM00IKD/TfaGmuG3
 2ohT0FFI4HYlUdVrmQnKWo1o/WbtWsUI12Fo2F1Kj+swgLz2Q2hSBujKt+DSUcdf5aed
 g+8w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20210112;
 h=x-gm-message-state:mime-version:from:date:message-id:subject:to:cc;
 bh=Jh6TD3HOJt6eAs1GuzJx9rq4K7ChpMIGA88NJ5qJr70=;
 b=g6ObKvb6BMIJWFjNjPf96vz9xDQ0ZS/IW5TPjv5CQwQZC4gJ9KCrG5R23fbpJHaOVm
 iJjlR1ymWEsq5Lu04vtY5hkLJE5s9CCwSJbEEwNYLdm4xCwgn9If3YM1SV3cYPKLTVag
 G8gglUoW8YlecWLYvIaTj+ri9qY/LTJfaCL0nf5kjI2kDrAQ907NXhrWQneDOVfC3C4m
 8e9oMSHy1ApGXT1SewmceIlQ0gThqMyzheXRT2LDRVYbOA2xyLSIMkRTyxbhco1Aktxb
 Qs+4lFZr1hsj22eM3UdB3oM7ABU9g7QAKqMuBBC4QkVs2aS4pbReqmJR8bTPzg4ziIoS
 WyVw==
X-Gm-Message-State: AOAM532dmCZzZKIL9bxHT5eleXgKYK2+60rxAO7/q8z5vdS3Tw260Y0B
 3b/TxdsfvLPEgCeyf7/XPWqwSs7hi3rY4LMJpaGCkeY27DDQ
X-Google-Smtp-Source: ABdhPJxzp3L11ka2c2WpRN7wS9s0UDqjwLJ9gcUbcfzdMN9x41C7wUVgGC02N+H3LisKfzQgQOOvoeZiuhs28KqgS3I=
X-Received: by 2002:a05:6808:1281:b0:2d9:a01a:4bd6 with SMTP id
 a1-20020a056808128100b002d9a01a4bd6mr5862526oiw.253.1646986734032; Fri, 11
 Mar 2022 00:18:54 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 11 Mar 2022 16:18:43 +0800
Message-ID: <CACzn6-UFqbF+rb1wvDJQ=6+jrHDsEZUufa8AG6vY5izH+KNNVg@mail.gmail.com>
To: Lustre-devel <lustre-devel@lists.lustre.org>
Subject: [lustre-devel] lustre:pcc: Sanity-pcc 7a test hang(Both on Aarch64
 and X86_64) discussion
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
Cc: Li Xi <lixi@ddn.com>
Content-Type: multipart/mixed; boundary="===============3730844255725045327=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============3730844255725045327==
Content-Type: multipart/alternative; boundary="0000000000003b6be005d9ecfb85"

--0000000000003b6be005d9ecfb85
Content-Type: text/plain; charset="UTF-8"

Hi,

Recently we've worked on the bug https://jira.whamcloud.com/browse/LU-14346.
This bug will make the *mmap write* hang forever. This one is first
occurring on Aarch64, but if we do a small change
<https://github.com/kevinzs2048/devbox/blob/master/notes/lustre/pcc_sanity-pcc-7a-analysis.md#reproduced-on-x86_64-with-a-small-change>,
we *can easily reproduce it on X86_64*. For more details analysis of this
bug, you can also check the link
<https://github.com/kevinzs2048/devbox/blob/master/notes/lustre/pcc_sanity-pcc-7a-analysis.md>
.

The hang location is here
<https://github.com/lustre/lustre-release/blob/master/lustre/tests/multiop.c#L725>
as
below:
==============
    case 'W':
        for (i = 0; i < mmap_len && mmap_ptr; i += 4096)
            mmap_ptr[i] += junk++;
        break;
===============

*Bug Analysis - different behavior when run **mmap_ptr[i] += junk++ on
different platform.*
Traditionally, this process is:
1. read from mmap_ptr[i]first(Execute the read page fault)
2. Write a value to the same page(execute the page_mkwrite to change the
page to writable).

But on different platforms, it executes quite differently.
On aarch64 platform: do_page_fault, no FAULT_FLAG_WRITE set, so
handle_pte_fault will call do_read_fault

   - do_read_fault:
               __do_fault -> call ll_fault, get a page from pcc_fault
               finish_fault(map the returned page to page tables)
               unlock_page
               vmf->flags is VM_FAULT_LOCKED
   - call do_wp_page --> do_page_mkwrite --> ll_page_mkwrite

On X86_64 platform, the mechanism is different. On X86_64, do_page_fault,
with *FAULT_FLAG_WRITE set*, so handle_pte_fault will call *do_shared_fault*
.

   - do_shared_fault
      -  __do_fault -> call ll_fault, get a page from pcc_fault
      - do_page_mkwrite-> call ll_page_mkwrite
      - finish_fault(map the returned page to page tables)
      - fault_dirty_shared_page

*Bug Analysis: why hang forever:*
Also can check:
https://github.com/kevinzs2048/devbox/blob/master/notes/lustre/pcc_sanity-pcc-7a-analysis.md#kernel-do_page_fault-process-analysis
for more details.

do_page_mkwrite--->ll_page_mkwrite.
    Insert the issue 0x1412 OBD_FAIL_LLITE_PCC_DETACH_MKWRITE.
    Return with VM_FAULT_RETRY | VM_FAULT_NOPAGE
    RETRY again, due to PTE is not NULL, vmf->flags FAULT_FLAG_WRITE, will
call do_wp_page again.
So that next time we will enter into do_page_mkwrite again. hanging forever.

*Seek a good solution*
As the above code snippet shows, *we want to let the kernel retry the mmap
write (->fault() and ->page_mkwrite).*
In handle_pte_fault, if there is no page or the page is not mapped(no PTE
found), then
 __do_page_fault will try the memory fault handling.

The easy fix here is to* remove the page and page table entry when we do
fail injection in pcc_page_mkwrite.* But I don't find a good method to
execute this, so list the info here and ask for community help.

Some tried fix is:
add function: *generic_error_remove_page*, but the mapped page still can
not be unmapped successfully. The error log is here
<https://github.com/kevinzs2048/devbox/blob/master/notes/lustre/pcc_sanity-pcc-7a-analysis.md#solution>
.

Since I'm a newbie to Lustre and not quite familiar with the memory
management process, so please give some advice on this bug fix. Thanks in
advance.



*Best Regards*

*Kevin Zhao*

Tech Lead, LDCG Cloud Infrastructure

Linaro Vertical Technologies

IRC(freenode): kevinz

Slack(kubernetes.slack.com): kevinz

kevin.zhao@linaro.org | Mobile/Direct/Wechat:  +86 18818270915

--0000000000003b6be005d9ecfb85
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi,<div><br></div><div>Recently we&#39;ve worked on the bu=
g=C2=A0<a href=3D"https://jira.whamcloud.com/browse/LU-14346">https://jira.=
whamcloud.com/browse/LU-14346</a>. This bug will make the <b>mmap write</b>=
 hang forever. This one is first occurring on Aarch64, but if we do a <a hr=
ef=3D"https://github.com/kevinzs2048/devbox/blob/master/notes/lustre/pcc_sa=
nity-pcc-7a-analysis.md#reproduced-on-x86_64-with-a-small-change">small cha=
nge</a>, we <b>can easily reproduce it on X86_64</b>. For more details=C2=
=A0analysis of this bug, you can also<a href=3D"https://github.com/kevinzs2=
048/devbox/blob/master/notes/lustre/pcc_sanity-pcc-7a-analysis.md"> check t=
he link</a>.</div><div><br></div><div>The <a href=3D"https://github.com/lus=
tre/lustre-release/blob/master/lustre/tests/multiop.c#L725">hang location i=
s here</a>=C2=A0as below:<br>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>=
=C2=A0 =C2=A0 case &#39;W&#39;:<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 for (i =3D 0=
; i &lt; mmap_len &amp;&amp; mmap_ptr; i +=3D 4096)<br>=C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 mmap_ptr[i] +=3D junk++;<br>=C2=A0 =C2=A0 =C2=A0 =C2=
=A0 break;<br>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D</div><div><br><=
/div><div><b>Bug Analysis - different behavior when run=C2=A0</b><b>mmap_pt=
r[i] +=3D junk++ on different platform.</b></div><div>Traditionally, this p=
rocess is:<br>1. read from mmap_ptr[i]first(Execute the read page fault)<br=
>2. Write a value to the same page(execute the page_mkwrite to change the p=
age to writable).<br><br>But on different platforms, it executes quite diff=
erently.<br>On aarch64 platform: do_page_fault, no FAULT_FLAG_WRITE set, so=
 handle_pte_fault will call do_read_fault<ul><li>do_read_fault:<br>=C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __do_fault=C2=A0-&gt; call ll_fault, get=
 a page from pcc_fault<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 finish_=
fault(map the returned page to page tables)<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 unlock_page<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 vmf-=
&gt;flags is VM_FAULT_LOCKED</li><li>call do_wp_page --&gt; do_page_mkwrite=
 --&gt; ll_page_mkwrite</li></ul>On X86_64 platform, the mechanism is diffe=
rent. On X86_64, do_page_fault, with <b>FAULT_FLAG_WRITE set</b>, so handle=
_pte_fault will call <b>do_shared_fault</b>.<ul><li>do_shared_fault</li><ul=
><li>=C2=A0__do_fault -&gt; call ll_fault, get a page from pcc_fault</li><l=
i>do_page_mkwrite-&gt; call ll_page_mkwrite</li><li>finish_fault(map the re=
turned page to page tables)</li><li>fault_dirty_shared_page</li></ul></ul><=
/div><div><b>Bug Analysis: why hang forever:</b></div><div>Also can check:=
=C2=A0<a href=3D"https://github.com/kevinzs2048/devbox/blob/master/notes/lu=
stre/pcc_sanity-pcc-7a-analysis.md#kernel-do_page_fault-process-analysis">h=
ttps://github.com/kevinzs2048/devbox/blob/master/notes/lustre/pcc_sanity-pc=
c-7a-analysis.md#kernel-do_page_fault-process-analysis</a> for more details=
.</div><div><br></div><div>do_page_mkwrite---&gt;ll_page_mkwrite.<br>=C2=A0=
 =C2=A0 Insert the issue 0x1412 OBD_FAIL_LLITE_PCC_DETACH_MKWRITE.<br>=C2=
=A0 =C2=A0 Return with VM_FAULT_RETRY | VM_FAULT_NOPAGE<br>=C2=A0 =C2=A0 RE=
TRY again, due to PTE is not NULL, vmf-&gt;flags FAULT_FLAG_WRITE, will cal=
l do_wp_page again.<br>So that next time we will enter into do_page_mkwrite=
 again. hanging forever.<br></div><div><br></div><div><b>Seek a good soluti=
on</b></div>As the above code snippet shows, <b>we want to let the kernel r=
etry=C2=A0the mmap write (-&gt;fault() and -&gt;page_mkwrite).</b><br>In ha=
ndle_pte_fault, if there is no page or the page is not mapped(no PTE found)=
, then<br>=C2=A0__do_page_fault will try the memory fault handling. <br><br=
>The easy fix here is to<b> remove the page and page table entry when we do=
 fail injection in pcc_page_mkwrite.</b> But I don&#39;t find a good method=
 to execute this, so list the info here and ask for community help.<br><br>=
Some tried fix is:<br><div>add function: <b>generic_error_remove_page</b>, =
but the mapped page still can not be unmapped successfully. <a href=3D"http=
s://github.com/kevinzs2048/devbox/blob/master/notes/lustre/pcc_sanity-pcc-7=
a-analysis.md#solution">The error log is here</a>.<br></div><div><br></div>=
<div>Since I&#39;m a newbie to Lustre and not quite familiar with the memor=
y management process, so please=C2=A0give some advice on this bug fix. Than=
ks in advance.</div><div><br></div><div><br></div><div><br></div><div><div =
dir=3D"ltr" class=3D"gmail_signature" data-smartmail=3D"gmail_signature"><d=
iv dir=3D"ltr"><div><div dir=3D"ltr"><div><div dir=3D"ltr"><div dir=3D"ltr"=
><b>Best Regards</b><div><div style=3D"margin:0px;padding:0px 0px 20px;widt=
h:1262px"><div><div style=3D"margin:8px 0px 0px;padding:0px"><div><div dir=
=3D"ltr"><font><div dir=3D"ltr"><div dir=3D"ltr"><p class=3D"MsoNormal" sty=
le=3D"color:rgb(136,136,136);font-family:Roboto,RobotoDraft,Helvetica,Arial=
,sans-serif;font-size:medium"><b><span style=3D"font-size:11pt"><font color=
=3D"#38761d">Kevin Zhao</font></span></b></p><p class=3D"MsoNormal" style=
=3D"color:rgb(136,136,136);font-family:Roboto,RobotoDraft,Helvetica,Arial,s=
ans-serif;font-size:medium"><font color=3D"#757b80"><span style=3D"font-siz=
e:14.6667px">Tech Lead, LDCG Cloud Infrastructure</span></font></p><p class=
=3D"MsoNormal" style=3D"color:rgb(136,136,136);font-family:Roboto,RobotoDra=
ft,Helvetica,Arial,sans-serif;font-size:medium"><font color=3D"#757b80"><sp=
an style=3D"font-size:14.6667px">Linaro Vertical Technologies</span></font>=
</p><p class=3D"MsoNormal" style=3D"color:rgb(136,136,136);font-family:Robo=
to,RobotoDraft,Helvetica,Arial,sans-serif;font-size:medium"><font color=3D"=
#757b80"><span style=3D"font-size:14.6667px">IRC(freenode): kevinz</span></=
font></p><p class=3D"MsoNormal"><font color=3D"#757b80"><font color=3D"#888=
888" face=3D"Roboto, RobotoDraft, Helvetica, Arial, sans-serif"><span style=
=3D"font-size:14.6667px">Slack(</span></font><font face=3D"Roboto, RobotoDr=
aft, Helvetica, Arial, sans-serif"><span style=3D"font-size:14.6667px"><a h=
ref=3D"http://kubernetes.slack.com" target=3D"_blank">kubernetes.slack.com<=
/a>)</span></font><font color=3D"#888888" face=3D"Roboto, RobotoDraft, Helv=
etica, Arial, sans-serif"><span style=3D"font-size:14.6667px">: kevinz</spa=
n></font></font></p><p class=3D"MsoNormal" style=3D"color:rgb(136,136,136);=
font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-size:medium"=
><font color=3D"#757b80"><span style=3D"font-size:14.6667px"><a href=3D"mai=
lto:kevin.zhao@linaro.org" target=3D"_blank"><span>kevin.zhao@linaro.org</s=
pan></a>=C2=A0| Mobile/Direct/Wechat:=C2=A0 +86 18818270915</span></font><s=
pan style=3D"color:rgb(117,123,128);font-size:11pt">=C2=A0</span><br></p><d=
iv style=3D"color:rgb(136,136,136);font-family:Roboto,RobotoDraft,Helvetica=
,Arial,sans-serif;font-size:medium"><span style=3D"color:rgb(117,123,128);f=
ont-size:11pt"><br></span></div></div></div></font></div><div style=3D"font=
-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-size:medium"></d=
iv></div></div><div style=3D"font-family:Roboto,RobotoDraft,Helvetica,Arial=
,sans-serif;font-size:medium"></div></div></div></div></div></div></div></d=
iv></div></div></div></div></div>

--0000000000003b6be005d9ecfb85--

--===============3730844255725045327==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============3730844255725045327==--

Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 820D9C47DDB
	for <lustre-devel@archiver.kernel.org>; Fri, 26 Jan 2024 22:25:02 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4TMC1H2sC2z1yCS;
	Fri, 26 Jan 2024 14:24:51 -0800 (PST)
Received: from mail-wm1-f41.google.com (mail-wm1-f41.google.com
 [209.85.128.41])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4TMC1F0107z1y5t
 for <lustre-devel@lists.lustre.org>; Fri, 26 Jan 2024 14:24:48 -0800 (PST)
Received: by mail-wm1-f41.google.com with SMTP id
 5b1f17b1804b1-40ee9e21fcdso5643905e9.0
 for <lustre-devel@lists.lustre.org>; Fri, 26 Jan 2024 14:24:48 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1706307887; x=1706912687; darn=lists.lustre.org;
 h=mime-version:content-language:accept-language:in-reply-to
 :references:message-id:date:thread-index:thread-topic:subject:to
 :from:from:to:cc:subject:date:message-id:reply-to;
 bh=/oQvPtQB69sWtBT5laJpxmh2Lioi2NY+XGXVnjTb+GI=;
 b=W0Z1qjO9hJqNqXKInUNxhI7uLApyeJ79+j40eza5GCh2xP6Gkn9BdlSrZ+L5GkoDlC
 HKpZ5Z+MyXAIueyTn/kDubG0tQ9EIpzaVLpFxAnatvMq9XTu2FBlvsStxp3CUUnornyh
 5ZhkIgNBaScYpIa9yE20+l8MelZ+nxY86/oDBY0ynQEhPTDbAziHf6NF5Ckdk4m+OkEW
 wtNNMQdtxmakFG3hgBo5L8F+X5cESTislgsIn35IlpSd+HMnpfCoXqsvj7k75exlgGnh
 Gc1mbR+GaCsFIDM8wg8YJEZIV63XwaosA3sJpRpHfl6BclIebfHKTHpRM/rgB8uFePN+
 0UIg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1706307887; x=1706912687;
 h=mime-version:content-language:accept-language:in-reply-to
 :references:message-id:date:thread-index:thread-topic:subject:to
 :from:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
 bh=/oQvPtQB69sWtBT5laJpxmh2Lioi2NY+XGXVnjTb+GI=;
 b=uYHRDVlWPEY4X8Y1pvPWENPNNgI/WW8+lHs5Ra1karpNVgP8hp06s+gT1Y7tIg2tl3
 Hs8Nr1vbevY27ORI4kWqTBwEZxASQDmln2CwAPl3Vgq0sybOx4Wgomrx7jZwPVVOTDiv
 dVuI1rHp+NZM59Yu24iyqzwb4WgBbDuW8hmhwQdY+QX+FzvCoa8iPPIqUeQZfxxoqk9C
 n0UqDOTOB1sUrMujZKZG+7QhYkyQpPHIuK43iHksM1o2nF1DKqnZsJETonxjUuNT+4F5
 YJ9rE+qHpbdvTuA0RleO5UGUknL4Z4D1155E0fLGqlrx1jQmJ9w6GBpOJfQ1kLA95/rJ
 ppDg==
X-Gm-Message-State: AOJu0YzY4MEmKtnDIQypStFzD1NBSm7aHY6Aiq17dlj5zUOS5C0uv7xV
 EN9wePE0u2iszfoB+TZ7yzVtLvPHWmqpWUgSWabugRMmrnKQt19Dqx9RhrEI
X-Google-Smtp-Source: AGHT+IGm58PcT4uBKyMTS6z5dmRDOj1C5OmS1XirYaqbPFK4TFOfso4HnBxNwkjttRkJXAvO8vlfzA==
X-Received: by 2002:a05:600c:3550:b0:40d:855c:ccef with SMTP id
 i16-20020a05600c355000b0040d855cccefmr330324wmq.22.1706307886633; 
 Fri, 26 Jan 2024 14:24:46 -0800 (PST)
Received: from LO2P265MB7274.GBRP265.PROD.OUTLOOK.COM ([2603:1026:c06:ff::5])
 by smtp.gmail.com with ESMTPSA id
 w18-20020a05600c475200b0040e9f7308f4sm2980300wmo.10.2024.01.26.14.24.45
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Fri, 26 Jan 2024 14:24:46 -0800 (PST)
To: Saisha Kamat <skamat1@charlotte.edu>, "lustre-devel@lists.lustre.org"
 <lustre-devel@lists.lustre.org>
Thread-Topic: [lustre-devel] Direct Modification of Lustre Metadata on Disk
Thread-Index: AXdKbVZCfmhPGjKhrS7L2pL4tXTHesYMWg0O
X-MS-Exchange-MessageSentRepresentingType: 1
Date: Fri, 26 Jan 2024 22:24:45 +0000
Message-ID: <LO2P265MB7274C2E5806D5C1E9655B5B4AB792@LO2P265MB7274.GBRP265.PROD.OUTLOOK.COM>
References: <CACyzrcQosBre=vRYDN+VeB=o=9bB-mJGT=NrQBhJi_59Eqe7jw@mail.gmail.com>
In-Reply-To: <CACyzrcQosBre=vRYDN+VeB=o=9bB-mJGT=NrQBhJi_59Eqe7jw@mail.gmail.com>
Accept-Language: ru-RU, en-US
Content-Language: en-GB
X-MS-Has-Attach: 
X-MS-Exchange-Organization-SCL: -1
X-MS-TNEF-Correlator: 
X-MS-Exchange-Organization-RecordReviewCfmType: 0
MIME-Version: 1.0
Subject: Re: [lustre-devel] Direct Modification of Lustre Metadata on Disk
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
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
From: Blagodarenko Artem via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Blagodarenko Artem <artem.blagodarenko@gmail.com>
Content-Type: multipart/mixed; boundary="===============5485143109616008455=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============5485143109616008455==
Content-Language: en-GB
Content-Type: multipart/alternative;
	boundary="_000_LO2P265MB7274C2E5806D5C1E9655B5B4AB792LO2P265MB7274GBRP_"

--_000_LO2P265MB7274C2E5806D5C1E9655B5B4AB792LO2P265MB7274GBRP_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi Saisha,

Thanks for your interest in Lustre FS and research efforts.
Regarding your question. Had MDS been mounted when there was the xattre dir=
ect modification attempt?
If yes, then xattr data consistency is not guaranteed.
If it is possible, unmount MDS, make modifications, and mount it back.

If MDS backend is LDISKFS, after unmounting MDS, you can mount it as

Mount -t ldiskfs <path_to_dev> <mount_point> and modify any file.
There is also debugfs utility which allows perform many useful modification=
s without mounting.

Best regards,
Artem Blagodarenko

Best rega
From: lustre-devel lustre-devel-bounces@lists.lustre.org<mailto:lustre-deve=
l-bounces@lists.lustre.org> on behalf of Saisha Kamat via lustre-devel lust=
re-devel@lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
Date: Friday, 26 January 2024 at 19:58
To: lustre-devel@lists.lustre.org<mailto:lustre-devel@lists.lustre.org> lus=
tre-devel@lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
Subject: [lustre-devel] Direct Modification of Lustre Metadata on Disk
Hello,

I am a Ph.D. student at UNC-Charlotte, focusing on research related to
the Lustre File System. As part of my project, I am investigating
scenarios involving the direct modification of xattr metadata on the
Lustre disk, without unmounting the Lustre servers.

To achieve this, I have attempted to open the MDS (Metadata Server)
disk partition as a file descriptor, locate the target file and its
xattr, and write a faulty value. However, I have encountered an
unexpected issue where my changes appear to be saved to memory and are
not being synchronized with the disk.
After completing the write operation, when I read the same xattr
again, it reflects the corrupted value. Strangely, when using the
"getfattr" command, the original, correct value is displayed. This
discrepancy has raised doubts about whether Lustre permits direct
modifications to its metadata on the disk.
Furthermore, I observed that even after unmounting and remounting the
Lustre file system, the xattr continues to display the corrupted value
upon reading, whereas "getfattr" still returns the original, correct
value.

Please help me understand whether Lustre allows direct modifications
to its metadata on the disk and if there are any inherent limitations
or considerations that I should be aware of.
Additionally, any recommendations or alternative approaches for
simulating faulty conditions for testing purposes would be highly
valuable to my research.

Thanks and Regards,
Saisha
_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org


--_000_LO2P265MB7274C2E5806D5C1E9655B5B4AB792LO2P265MB7274GBRP_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:o=3D"urn:schemas-microsoft-com:office:office" xmlns:w=3D"urn:sc=
hemas-microsoft-com:office:word" xmlns:m=3D"http://schemas.microsoft.com/of=
fice/2004/12/omml" xmlns=3D"http://www.w3.org/TR/REC-html40">
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
<meta name=3D"Generator" content=3D"Microsoft Word 15 (filtered medium)">
<style><!--
/* Font Definitions */
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
@font-face
	{font-family:Aptos;
	panose-1:2 11 0 4 2 2 2 2 2 4;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0cm;
	font-size:10.0pt;
	font-family:"Calibri",sans-serif;}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:blue;
	text-decoration:underline;}
.MsoChpDefault
	{mso-style-type:export-only;
	font-size:10.0pt;
	mso-ligatures:none;}
@page WordSection1
	{size:612.0pt 792.0pt;
	margin:72.0pt 72.0pt 72.0pt 72.0pt;}
div.WordSection1
	{page:WordSection1;}
--></style>
</head>
<body lang=3D"EN-GB" link=3D"blue" vlink=3D"purple" style=3D"word-wrap:brea=
k-word">
<div class=3D"WordSection1">
<div id=3D"mail-editor-reference-message-container">
<div>
<div>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt;mso-fareast-language=
:EN-US">Hi Saisha,<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt;mso-fareast-language=
:EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt;mso-fareast-language=
:EN-US">Thanks for your interest in Lustre FS and research efforts.<o:p></o=
:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt;mso-fareast-language=
:EN-US">Regarding your question. Had MDS been mounted when there was the xa=
ttre direct modification attempt?<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt;mso-fareast-language=
:EN-US">If yes, then xattr data consistency is not guaranteed.<o:p></o:p></=
span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt;mso-fareast-language=
:EN-US">If it is possible, unmount MDS, make modifications, and mount it ba=
ck.<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt;mso-fareast-language=
:EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt;mso-fareast-language=
:EN-US">If MDS backend is LDISKFS, after unmounting MDS, you can mount it a=
s
<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt;mso-fareast-language=
:EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt;mso-fareast-language=
:EN-US">Mount -t ldiskfs &lt;path_to_dev&gt; &lt;mount_point&gt; and modify=
 any file.<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt;mso-fareast-language=
:EN-US">There is also debugfs utility which allows perform many useful modi=
fications without mounting.<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt;mso-fareast-language=
:EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt;mso-fareast-language=
:EN-US">Best regards,<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt;mso-fareast-language=
:EN-US">Artem Blagodarenko<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt;mso-fareast-language=
:EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt;mso-fareast-language=
:EN-US">Best rega<o:p></o:p></span></p>
<p class=3D"MsoNormal" style=3D"margin-bottom:12.0pt"><b><span style=3D"fon=
t-size:12.0pt;font-family:&quot;Aptos&quot;,sans-serif;color:black">From:
</span></b><span style=3D"font-size:12.0pt;font-family:&quot;Aptos&quot;,sa=
ns-serif;color:black">lustre-devel
</span><a href=3D"mailto:lustre-devel-bounces@lists.lustre.org"><span style=
=3D"font-size:12.0pt;font-family:&quot;Aptos&quot;,sans-serif">lustre-devel=
-bounces@lists.lustre.org</span></a><span style=3D"font-size:12.0pt;font-fa=
mily:&quot;Aptos&quot;,sans-serif;color:black"> on behalf
 of Saisha Kamat via lustre-devel </span><a href=3D"mailto:lustre-devel@lis=
ts.lustre.org"><span style=3D"font-size:12.0pt;font-family:&quot;Aptos&quot=
;,sans-serif">lustre-devel@lists.lustre.org</span></a><span style=3D"font-s=
ize:12.0pt;font-family:&quot;Aptos&quot;,sans-serif;color:black"><br>
<b>Date: </b>Friday, 26 January 2024 at 19:58<br>
<b>To: </b></span><a href=3D"mailto:lustre-devel@lists.lustre.org"><span st=
yle=3D"font-size:12.0pt;font-family:&quot;Aptos&quot;,sans-serif">lustre-de=
vel@lists.lustre.org</span></a><span style=3D"font-size:12.0pt;font-family:=
&quot;Aptos&quot;,sans-serif;color:black">
</span><a href=3D"mailto:lustre-devel@lists.lustre.org"><span style=3D"font=
-size:12.0pt;font-family:&quot;Aptos&quot;,sans-serif">lustre-devel@lists.l=
ustre.org</span></a><span style=3D"font-size:12.0pt;font-family:&quot;Aptos=
&quot;,sans-serif;color:black"><br>
<b>Subject: </b>[lustre-devel] Direct Modification of Lustre Metadata on Di=
sk<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt">Hello,<br>
<br>
I am a Ph.D. student at UNC-Charlotte, focusing on research related to<br>
the Lustre File System. As part of my project, I am investigating<br>
scenarios involving the direct modification of xattr metadata on the<br>
Lustre disk, without unmounting the Lustre servers.<br>
<br>
To achieve this, I have attempted to open the MDS (Metadata Server)<br>
disk partition as a file descriptor, locate the target file and its<br>
xattr, and write a faulty value. However, I have encountered an<br>
unexpected issue where my changes appear to be saved to memory and are<br>
not being synchronized with the disk.<br>
After completing the write operation, when I read the same xattr<br>
again, it reflects the corrupted value. Strangely, when using the<br>
&quot;getfattr&quot; command, the original, correct value is displayed. Thi=
s<br>
discrepancy has raised doubts about whether Lustre permits direct<br>
modifications to its metadata on the disk.<br>
Furthermore, I observed that even after unmounting and remounting the<br>
Lustre file system, the xattr continues to display the corrupted value<br>
upon reading, whereas &quot;getfattr&quot; still returns the original, corr=
ect<br>
value.<br>
<br>
Please help me understand whether Lustre allows direct modifications<br>
to its metadata on the disk and if there are any inherent limitations<br>
or considerations that I should be aware of.<br>
Additionally, any recommendations or alternative approaches for<br>
simulating faulty conditions for testing purposes would be highly<br>
valuable to my research.<br>
<br>
Thanks and Regards,<br>
Saisha<br>
_______________________________________________<br>
lustre-devel mailing list<br>
</span><a href=3D"mailto:lustre-devel@lists.lustre.org"><span style=3D"font=
-size:11.0pt">lustre-devel@lists.lustre.org</span></a><span style=3D"font-s=
ize:11.0pt"><br>
</span><a href=3D"http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.=
org"><span style=3D"font-size:11.0pt">http://lists.lustre.org/listinfo.cgi/=
lustre-devel-lustre.org</span></a><span style=3D"font-size:11.0pt"><o:p></o=
:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt"><o:p>&nbsp;</o:p></=
span></p>
</div>
</div>
</div>
</div>
</body>
</html>

--_000_LO2P265MB7274C2E5806D5C1E9655B5B4AB792LO2P265MB7274GBRP_--

--===============5485143109616008455==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============5485143109616008455==--

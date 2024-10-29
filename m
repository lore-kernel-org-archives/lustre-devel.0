Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 49774D3A697
	for <lustre-devel@archiver.kernel.org>; Tue, 29 Oct 2024 19:39:29 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4XdLDL1rCtz1xBm;
	Tue, 29 Oct 2024 12:39:14 -0700 (PDT)
Received: from mail-pg1-f178.google.com (mail-pg1-f178.google.com
 [209.85.215.178])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4XdLDF0s5dz1wLq; Tue, 29 Oct 2024 12:39:09 -0700 (PDT)
Received: by mail-pg1-f178.google.com with SMTP id
 41be03b00d2f7-7ea7ad1e01fso159270a12.0; 
 Tue, 29 Oct 2024 12:39:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1730230748; x=1730835548; darn=lists.lustre.org;
 h=mime-version:subject:references:in-reply-to:message-id:to:from:date
 :from:to:cc:subject:date:message-id:reply-to;
 bh=mhx8ixrVol4WW3TOVlEjk7VEMJD5zbQ9C5yzgHfvKGQ=;
 b=Ik+lL25lUse01HJuPWsiK8FhTHxozUwFqlyp7b4Hszih+ww9XMXg8Yez8bIUmf1pXz
 hv6ENonHRbGSsygqYQzFUOlWnsWxOVr89pOQVBHi+8VwfeCgQFKFPIpV95A9XD6zeHQ8
 f9pntE3K18MqAV28yVp1aMN6O+T0AF6vMSMbGOZ+Hbx5TLk72YcOKOw4/6zjBue4HdnW
 bfugttrApJYb/hZDwljR/MfFhEgb9TgUV6bPn7hH/sr8z+1yyBQvvRurAPttyvjwSQk8
 FwZ0XtQqEd01C+KcM+vdGuulI1NKlYs7WvUhEOTlOQNUU222e8d5pU2nmcYLUm6Pmbry
 JR1A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1730230748; x=1730835548;
 h=mime-version:subject:references:in-reply-to:message-id:to:from:date
 :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
 bh=mhx8ixrVol4WW3TOVlEjk7VEMJD5zbQ9C5yzgHfvKGQ=;
 b=Ns/CQ9XpEYohg1y9rrVpiJe+Zo+C+v0/1n4eVpcwqN1XWhL4mZR7BBxc1zs6YI6sKs
 UwI3SthHY1zHkgiLdc61OHq+zIuX8mJlxDsBU5qqav88pTjq21od+G8p8r9vvvMkMcTh
 dPIKDgNPnxc7mOh7cfroe4Gq0oyQmyPtOaIQOH0zQur/CZHyRBvJsqIPDy134NNSYugu
 jhbOvoG7djjkNkwXrte7Lx8aW+FYIX8vsEjqgYlG867vM2SDvVzrRmwDz6yItoreMWWF
 p8y67941EPJbJalOMDR8JZcGoGKw3nWjxtqQH+iSFGPwQdaBQsUK8yrlVuMps7nfkne2
 6+sg==
X-Forwarded-Encrypted: i=1;
 AJvYcCUn6dRpJHWk2xNKNKE+GmVpfEgKpGakCuyNLWqwpHws06FXto5UI2w9qY9P37ty3Jm+M+5doQxqJsz04rvStA==@lists.lustre.org
X-Gm-Message-State: AOJu0YxkZhownF8xsVUc9ID78cfXCnMgJwFiCrWXfILMxGCafACflip6
 wJ5rf/efBDWMk5liCeXU3TGstEskC5gL7ZC7YlLUd6MObPzSS5dJyTf3TA==
X-Google-Smtp-Source: AGHT+IHnVI3d6ZbvRY7gPGcUo7dsaw7nN82J+kFWEOzLZLQMIqw6CzkK87ElyFEQEDKr/m/cYmlaeg==
X-Received: by 2002:a05:6a21:4d8c:b0:1d9:1a32:5b4e with SMTP id
 adf61e73a8af0-1d9e1ede2d6mr4939317637.4.1730230747641; 
 Tue, 29 Oct 2024 12:39:07 -0700 (PDT)
Received: from [192.168.86.58] (97-115-66-118.ptld.qwest.net. [97.115.66.118])
 by smtp.gmail.com with ESMTPSA id
 d2e1a72fcca58-72057931870sm7875910b3a.64.2024.10.29.12.39.06
 (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
 Tue, 29 Oct 2024 12:39:07 -0700 (PDT)
Date: Tue, 29 Oct 2024 12:38:57 -0700
From: Nathan Rutman <nrutman@gmail.com>
To: lustre-devel@lists.lustre.org, lustre-discuss@lists.lustre.org
Message-ID: <250f2f80-76dc-4f59-92c7-fc5e4465b753@Spark>
In-Reply-To: <8c491303-89e9-439e-a39b-0cab2dbd8e66@Spark>
References: <8c491303-89e9-439e-a39b-0cab2dbd8e66@Spark>
X-Readdle-Message-ID: 250f2f80-76dc-4f59-92c7-fc5e4465b753@Spark
MIME-Version: 1.0
Subject: [lustre-devel] Stripe visualization tool
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
Content-Type: multipart/mixed; boundary="===============1767702295650738803=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============1767702295650738803==
Content-Type: multipart/alternative; boundary="672139d6_59e3ef69_2520"

--672139d6_59e3ef69_2520
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

In the =46WIW category, I've got a tool to graphically display a file's s=
triping pattern for arbitrary Lustre files. It takes in the yaml from =22=
getstripe -y=22 and will generate a jpeg. Handles DoM, P=46L, overstripin=
g, mirroring, pools. Available at=C2=A0https://github.com/HewlettPackard/=
lustre-stripe-plotter


Example of mirrored DoM P=46L file:

--672139d6_59e3ef69_2520
Content-Type: multipart/related; boundary="672139d6_5d12a757_2520"

--672139d6_5d12a757_2520
Content-Type: text/html; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

<html xmlns=3D=22http://www.w3.org/1999/xhtml=22>
<head>
<title></title>
</head>
<body>
<div name=3D=22messageBodySection=22>
<div dir=3D=22auto=22>In the =46WIW category, I've got a tool to graphica=
lly display a file's striping pattern for arbitrary Lustre files. It take=
s in the yaml from =22getstripe -y=22 and will generate a jpeg. Handles D=
oM, P=46L, overstriping, mirroring, pools. Available at&=23160;<a href=3D=
=22https://github.com/HewlettPackard/lustre-stripe-plotter=22 target=3D=22=
=5Fblank=22>https://github.com/HewlettPackard/lustre-stripe-plotter</a><s=
pan style=3D=22font-size: 16px=22><br /></span><span style=3D=22font-size=
: 16px=22><br /></span><span style=3D=22font-size: 16px=22><br /></span><=
span style=3D=22color:=231f2328;font-family:-apple-system, system-ui, Seg=
oe UI, Noto Sans, Helvetica, Arial, sans-serif, Apple Color Emoji, Segoe =
UI Emoji;font-size: 16px=22>Example of mirrored DoM P=46L file:</span><sp=
an style=3D=22font-size: 16px=22><br /></span><img style=3D=22max-width:1=
00%;height:auto=22 src=3D=22cid:D8E0AA=4621B7746BEA216C2150A875126=22 /><=
/div>
</div>
</body>
</html>

--672139d6_5d12a757_2520
Content-Type: image/jpeg
Content-Transfer-Encoding: base64
Content-ID: <D8E0AAF21B7746BEA216C2150A875126>
Content-Disposition: inline; filename="Attachment.jpeg"

/9j/4AAQSkZJRgABAQAASABIAAD/4QBARXhpZgAATU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAA
AqACAAQAAAABAAABQKADAAQAAAABAAAAhQAAAAD/7QA4UGhvdG9zaG9wIDMuMAA4QklNBAQAAAAA
AAA4QklNBCUAAAAAABDUHYzZjwCyBOmACZjs+EJ+/+IH2ElDQ19QUk9GSUxFAAEBAAAHyGFwcGwC
IAAAbW50clJHQiBYWVogB9kAAgAZAAsAGgALYWNzcEFQUEwAAAAAYXBwbAAAAAAAAAAAAAAAAAAA
AAAAAPbWAAEAAAAA0y1hcHBsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAALZGVzYwAAAQgAAABvZHNjbQAAAXgAAAWKY3BydAAABwQAAAA4d3RwdAAABzwAAAAU
clhZWgAAB1AAAAAUZ1hZWgAAB2QAAAAUYlhZWgAAB3gAAAAUclRSQwAAB4wAAAAOY2hhZAAAB5wA
AAAsYlRSQwAAB4wAAAAOZ1RSQwAAB4wAAAAOZGVzYwAAAAAAAAAUR2VuZXJpYyBSR0IgUHJvZmls
ZQAAAAAAAAAAAAAAFEdlbmVyaWMgUkdCIFByb2ZpbGUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAG1sdWMAAAAAAAAAHwAAAAxza1NLAAAAKAAAAYRkYURL
AAAAJAAAAaxjYUVTAAAAJAAAAdB2aVZOAAAAJAAAAfRwdEJSAAAAJgAAAhh1a1VBAAAAKgAAAj5m
ckZVAAAAKAAAAmhodUhVAAAAKAAAApB6aFRXAAAAEgAAArhrb0tSAAAAFgAAAspuYk5PAAAAJgAA
AuBjc0NaAAAAIgAAAwZoZUlMAAAAHgAAAyhyb1JPAAAAJAAAA0ZkZURFAAAALAAAA2ppdElUAAAA
KAAAA5ZzdlNFAAAAJgAAAuB6aENOAAAAEgAAA75qYUpQAAAAGgAAA9BlbEdSAAAAIgAAA+pwdFBP
AAAAJgAABAxubE5MAAAAKAAABDJlc0VTAAAAJgAABAx0aFRIAAAAJAAABFp0clRSAAAAIgAABH5m
aUZJAAAAKAAABKBockhSAAAAKAAABMhwbFBMAAAALAAABPBydVJVAAAAIgAABRxlblVTAAAAJgAA
BT5hckVHAAAAJgAABWQAVgFhAGUAbwBiAGUAYwBuAP0AIABSAEcAQgAgAHAAcgBvAGYAaQBsAEcA
ZQBuAGUAcgBlAGwAIABSAEcAQgAtAHAAcgBvAGYAaQBsAFAAZQByAGYAaQBsACAAUgBHAEIAIABn
AGUAbgDoAHIAaQBjAEMepQB1ACAAaADsAG4AaAAgAFIARwBCACAAQwBoAHUAbgBnAFAAZQByAGYA
aQBsACAAUgBHAEIAIABHAGUAbgDpAHIAaQBjAG8EFwQwBDMEMAQ7BEwEPQQ4BDkAIAQ/BEAEPgRE
BDAEOQQ7ACAAUgBHAEIAUAByAG8AZgBpAGwAIABnAOkAbgDpAHIAaQBxAHUAZQAgAFIAVgBCAMEA
bAB0AGEAbADhAG4AbwBzACAAUgBHAEIAIABwAHIAbwBmAGkAbJAadSgAUgBHAEKCcl9pY8+P8Md8
vBgAIABSAEcAQgAg1QS4XNMMx3wARwBlAG4AZQByAGkAcwBrACAAUgBHAEIALQBwAHIAbwBmAGkA
bABPAGIAZQBjAG4A/QAgAFIARwBCACAAcAByAG8AZgBpAGwF5AXoBdUF5AXZBdwAIABSAEcAQgAg
BdsF3AXcBdkAUAByAG8AZgBpAGwAIABSAEcAQgAgAGcAZQBuAGUAcgBpAGMAQQBsAGwAZwBlAG0A
ZQBpAG4AZQBzACAAUgBHAEIALQBQAHIAbwBmAGkAbABQAHIAbwBmAGkAbABvACAAUgBHAEIAIABn
AGUAbgBlAHIAaQBjAG9mbpAaAFIARwBCY8+P8GWHTvZOAIIsACAAUgBHAEIAIDDXMO0w1TChMKQw
6wOTA7UDvQO5A7oDzAAgA8ADwQO/A8YDrwO7ACAAUgBHAEIAUABlAHIAZgBpAGwAIABSAEcAQgAg
AGcAZQBuAOkAcgBpAGMAbwBBAGwAZwBlAG0AZQBlAG4AIABSAEcAQgAtAHAAcgBvAGYAaQBlAGwO
Qg4bDiMORA4fDiUOTAAgAFIARwBCACAOFw4xDkgOJw5EDhsARwBlAG4AZQBsACAAUgBHAEIAIABQ
AHIAbwBmAGkAbABpAFkAbABlAGkAbgBlAG4AIABSAEcAQgAtAHAAcgBvAGYAaQBpAGwAaQBHAGUA
bgBlAHIAaQENAGsAaQAgAFIARwBCACAAcAByAG8AZgBpAGwAVQBuAGkAdwBlAHIAcwBhAGwAbgB5
ACAAcAByAG8AZgBpAGwAIABSAEcAQgQeBDEESQQ4BDkAIAQ/BEAEPgREBDgEOwRMACAAUgBHAEIA
RwBlAG4AZQByAGkAYwAgAFIARwBCACAAUAByAG8AZgBpAGwAZQZFBkQGQQAgBioGOQYxBkoGQQAg
AFIARwBCACAGJwZEBjkGJwZFAAB0ZXh0AAAAAENvcHlyaWdodCAyMDA3IEFwcGxlIEluYy4sIGFs
bCByaWdodHMgcmVzZXJ2ZWQuAFhZWiAAAAAAAADzUgABAAAAARbPWFlaIAAAAAAAAHRNAAA97gAA
A9BYWVogAAAAAAAAWnUAAKxzAAAXNFhZWiAAAAAAAAAoGgAAFZ8AALg2Y3VydgAAAAAAAAABAc0A
AHNmMzIAAAAAAAEMQgAABd7///MmAAAHkgAA/ZH///ui///9owAAA9wAAMBs/8AAEQgAhQFAAwEi
AAIRAQMRAf/EAB8AAAEFAQEBAQEBAAAAAAAAAAABAgMEBQYHCAkKC//EALUQAAIBAwMCBAMFBQQE
AAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2
Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Sl
pqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+v/EAB8B
AAMBAQEBAQEBAQEAAAAAAAABAgMEBQYHCAkKC//EALURAAIBAgQEAwQHBQQEAAECdwABAgMRBAUh
MQYSQVEHYXETIjKBCBRCkaGxwQkjM1LwFWJy0QoWJDThJfEXGBkaJicoKSo1Njc4OTpDREVGR0hJ
SlNUVVZXWFlaY2RlZmdoaWpzdHV2d3h5eoKDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2
t7i5usLDxMXGx8jJytLT1NXW19jZ2uLj5OXm5+jp6vLz9PX29/j5+v/bAEMAAQEBAQEBAgEBAgMC
AgIDBAMDAwMEBQQEBAQEBQYFBQUFBQUGBgYGBgYGBgcHBwcHBwgICAgICQkJCQkJCQkJCf/bAEMB
AQEBAgICBAICBAkGBQYJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJ
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
RRQAUUUUAFFFFABRRRQB/9k=

--672139d6_5d12a757_2520--

--672139d6_59e3ef69_2520--


--===============1767702295650738803==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============1767702295650738803==--


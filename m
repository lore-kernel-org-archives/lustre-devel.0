Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 7A1E7CCFA04
	for <lustre-devel@archiver.kernel.org>; Wed,  5 Nov 2025 00:47:22 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4d1RCw6x1Nz1whP;
	Tue, 04 Nov 2025 16:34:36 -0800 (PST)
Received: from mail-oa1-f45.google.com (mail-oa1-f45.google.com
 [209.85.160.45])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4d1RB93ZlXz20fJ
 for <lustre-devel@lists.lustre.org>; Tue, 04 Nov 2025 16:33:05 -0800 (PST)
Received: by mail-oa1-f45.google.com with SMTP id
 586e51a60fabf-3e10d1477afso595516fac.3
 for <lustre-devel@lists.lustre.org>; Tue, 04 Nov 2025 16:33:05 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=google.com; s=20230601; t=1762302664; x=1762907464; darn=lists.lustre.org;
 h=cc:to:subject:message-id:date:from:in-reply-to:references
 :mime-version:from:to:cc:subject:date:message-id:reply-to;
 bh=gDkZHYWqGhB936KI53o0+snC1VFza30YWBa/EKhLJP0=;
 b=PoxMmDKxPfco/KNQU80wWgeEeQ62Us7KUL7uAy1l9iaaOXrB2Y+LzECCNZ68mQ6IPz
 SkZZ8hqtJUN8m8ZLl1jF6ZljaAzbcKIOxKW2iH7IVkGAWmnt2VzSFNLw1c80PTDE3R/w
 EuUM2Y9mc0RGxeQImV48frIXeyectOHue8khX0qtB70+WIltV6g8t+w/CCACk+a4WICn
 Rd/TQTvrfRpwdSUvT/4u6IBeo1rLqvgaexmtXS4X0J0FDMsbAGjKBnvrQQJ4+l6fuwvq
 ryVRpF0oxupWpAUkPDHToMJViW3DD9UHdcujSTHj6xneSHgYoScwnI2aqXjDxVFN088x
 Ph1A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1762302664; x=1762907464;
 h=cc:to:subject:message-id:date:from:in-reply-to:references
 :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
 :reply-to;
 bh=gDkZHYWqGhB936KI53o0+snC1VFza30YWBa/EKhLJP0=;
 b=n9xPDc6GwIWMmOpz0a2anblKtYvSJDmJZbhBpVkUfSAxtYtwt23GpWZx+n4KXveJxu
 abAdi7BhQi75QIif7NwTfWqKQzrd151e2T/bhzBmTtqpyQnDa04E5uL6mKhYtZdLApkh
 dCjlLLtwqr1gib6+ExI0dG8a12JGm/j4NlCaZx1u7pew6u0tuu2fqgx9spcWm85o9A03
 4a0vjcPS5akcjez60LMSZqwE4mfrp+M+/HtYRbZT9OfOtIVvYwEJ9t3EI2CO1oX9ywQF
 EirrvWtg97S1yZqrrDWxKsROYtDTLZzvCgydycTzfG6iZKsL+7Fueq1o5xNO0HgjSCI9
 ju2g==
X-Forwarded-Encrypted: i=1;
 AJvYcCUz35Ommm3pF44WkVGGhyxT+cdcklQiYm3Bg59VdbVTeTFUMrgncCU8aAa4MUoJ/SyuPVB6H0CbrrUtk1Y=@lists.lustre.org
X-Gm-Message-State: AOJu0YwTij8O/kdYeeh3ssJ+xhWi7WD7jp09rxoS3Pc1hIvlrYC5JK5H
 ATH/hMrM9m8C+5a0HYmcoeX/q2odTyPuL1dmej1Znkuf48xd/0stI9E8L47109bOyJS4/T3u0w2
 ioTDRoGDUX+WT4T6z0ZYORl+g41xMcH5w69OrWp3m
X-Gm-Gg: ASbGncsGR+aSfYPuJxCO/d5UkW8Hm7iDbS/G0pE3QHAIEf8K99fscO9K5+FyRsyjSny
 ViNR1PZ8tZFgfscH3H6X27qEipLuYuFon71ady5p5Ycsc+xi+WOz8iRyVvUVN9uHfdaMEssIbEE
 rMDpUIAQ8hGSGVIlOn9vngWWZJq8NdilXpPlniVRvvu953rHUTobCvqTzHrvB5qnYMkhC8OxBZv
 pXrnmhi2F93mllZAUSOgFbV1lQSOaHmzSxc1dD4K8mEGgahCKFlbqAlw+da2qbJ2en2qZmZMWdv
 Ea8/PmyuLFz4+6BzIkjmxZpe6Xtz
X-Google-Smtp-Source: AGHT+IECI2DbpXHSKec2aYxaExv1j1BLbJJ+xZZFGwrSbCuP3tjnJUek6/D3MheKO2s1eahdhChJLt4IvbJNEc/k26k=
X-Received: by 2002:a05:6870:5e4e:b0:375:94a0:166d with SMTP id
 586e51a60fabf-3e199360603mr540536fac.5.1762302664308; Tue, 04 Nov 2025
 16:31:04 -0800 (PST)
MIME-Version: 1.0
References: <85EBE389-4753-454B-9735-B57039CB003A@amazon.com>
 <2AAB29BD-39BB-42E7-B142-45EA006571BD@ddn.com>
 <2820AB7F-9276-40E2-8C51-C62C9304B4B8@dilger.ca>
 <CAEp8vpi9nRVkBUes8-0RE9YFr7AUPUM+L4AU73UcVU_e6t3ehg@mail.gmail.com>
 <706AC712-F619-41CF-BD57-E12E3733F458@dilger.ca>
In-Reply-To: <706AC712-F619-41CF-BD57-E12E3733F458@dilger.ca>
Date: Tue, 4 Nov 2025 16:30:53 -0800
X-Gm-Features: AWmQ_bk9d_u77AeBh2oecSbpcLbISAhxfOFst7mrxAj8ruK0IFIqk4YxIsQWfzw
Message-ID: <CAEp8vpg9GEq4wnrNk96=TwnHcA6SVzNyNH11KoLnaqciOrY6Ag@mail.gmail.com>
To: Andreas Dilger <adilger@dilger.ca>
Subject: Re: [lustre-devel] RFC: Spill device for Lustre OSD
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
From: Jinshan Xiong via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Jinshan Xiong <jinshanx@google.com>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============7737040333725089555=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============7737040333725089555==
Content-Type: multipart/alternative; boundary="0000000000004b91270642ce1081"

--0000000000004b91270642ce1081
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, Nov 4, 2025 at 4:25=E2=80=AFPM Andreas Dilger <adilger@dilger.ca> w=
rote:

>
> On Nov 4, 2025, at 4:54 PM, Jinshan Xiong <jinshanx@google.com> wrote:
> > On Tue, Nov 4, 2025 at 3:48=E2=80=AFPM Andreas Dilger <adilger@dilger.c=
a> wrote:
> >>
> >> If the overhead of a local Lustre mount on the OSS is problematic, tha=
t
> >> seems like something which could/should be fixed?  The local mounts ar=
e
> >> already "non-recoverable" so that they do not get an entry in last_rcv=
d
> >> and their absence does not cause any recovery issues.
> >>
> >> The main issue we've seen with local mountpoints is that this can
> confuse
> >> HA and prevent Lustre module unloading if they are not taken into
> account
> >> during cleanup.
> >
> > You're right. That's actually why we didn't do it in the first place. I=
f
> an OSS crashes, it will definitely lead to recovery timeout and client
> eviction.
>
> If an OSS crash with a local mountpoint is causing recovery timeouts,
> then that seems like a bug to be fixed.  This was changed by Alex Z.
> in patch "LU-12722 target: disable recovery for local clients" back in
> commit v2_13_52-45-g8bd04b4e57.
>

Thanks for the context. My knowledge of Lustre is many years old ;-)


>
> Cheers, Andreas
>
>
>
>
>
>

--0000000000004b91270642ce1081
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><br></div><br><div class=3D"gmail_quote g=
mail_quote_container"><div dir=3D"ltr" class=3D"gmail_attr">On Tue, Nov 4, =
2025 at 4:25=E2=80=AFPM Andreas Dilger &lt;<a href=3D"mailto:adilger@dilger=
.ca">adilger@dilger.ca</a>&gt; wrote:<br></div><blockquote class=3D"gmail_q=
uote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,2=
04);padding-left:1ex"><br>
On Nov 4, 2025, at 4:54 PM, Jinshan Xiong &lt;<a href=3D"mailto:jinshanx@go=
ogle.com" target=3D"_blank">jinshanx@google.com</a>&gt; wrote:<br>
&gt; On Tue, Nov 4, 2025 at 3:48=E2=80=AFPM Andreas Dilger &lt;<a href=3D"m=
ailto:adilger@dilger.ca" target=3D"_blank">adilger@dilger.ca</a>&gt; wrote:=
<br>
&gt;&gt; <br>
&gt;&gt; If the overhead of a local Lustre mount on the OSS is problematic,=
 that<br>
&gt;&gt; seems like something which could/should be fixed?=C2=A0 The local =
mounts are<br>
&gt;&gt; already &quot;non-recoverable&quot; so that they do not get an ent=
ry in last_rcvd<br>
&gt;&gt; and their absence does not cause any recovery issues.<br>
&gt;&gt; <br>
&gt;&gt; The main issue we&#39;ve seen with local mountpoints is that this =
can confuse<br>
&gt;&gt; HA and prevent Lustre module unloading if they are not taken into =
account<br>
&gt;&gt; during cleanup.<br>
&gt; <br>
&gt; You&#39;re right. That&#39;s actually why we didn&#39;t do it in the f=
irst place. If an OSS crashes, it will definitely lead to recovery timeout =
and client eviction.<br>
<br>
If an OSS crash with a local mountpoint is causing recovery timeouts,<br>
then that seems like a bug to be fixed.=C2=A0 This was changed by Alex Z.<b=
r>
in patch &quot;LU-12722 target: disable recovery for local clients&quot; ba=
ck in<br>
commit v2_13_52-45-g8bd04b4e57.<br></blockquote><div><br></div><div>Thanks =
for the context. My knowledge of Lustre is many years old ;-)</div><div>=C2=
=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8e=
x;border-left:1px solid rgb(204,204,204);padding-left:1ex">
<br>
Cheers, Andreas<br>
<br>
<br>
<br>
<br>
<br>
</blockquote></div></div>

--0000000000004b91270642ce1081--

--===============7737040333725089555==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============7737040333725089555==--

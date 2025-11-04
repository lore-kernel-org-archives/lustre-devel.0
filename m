Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 5CCDACCFA04
	for <lustre-devel@archiver.kernel.org>; Wed,  5 Nov 2025 00:10:55 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4d1QMp4bq1z238L;
	Tue, 04 Nov 2025 15:56:22 -0800 (PST)
Received: from mail-ot1-f52.google.com (mail-ot1-f52.google.com
 [209.85.210.52])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4d1QM72TFHz1y4M
 for <lustre-devel@lists.lustre.org>; Tue, 04 Nov 2025 15:55:47 -0800 (PST)
Received: by mail-ot1-f52.google.com with SMTP id
 46e09a7af769-7c6d3676455so81138a34.2
 for <lustre-devel@lists.lustre.org>; Tue, 04 Nov 2025 15:55:47 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=google.com; s=20230601; t=1762300483; x=1762905283; darn=lists.lustre.org;
 h=cc:to:subject:message-id:date:from:in-reply-to:references
 :mime-version:from:to:cc:subject:date:message-id:reply-to;
 bh=RbHu+uwBsQBqJFRYbFeNydYwq6P0LanfKix6KtOp31g=;
 b=LRFRQRNOlJgc2PSlUv/WhXJF6A1aSMon97UWs4t7tVicH6bIFHpHXmUuieX98DPnfW
 sUKCMwMa6vuaXQLbvqHxfIoVMP7aOoQwM8YBWEt8uQXk58Sp6El+tpIfMKXo1iejKmS5
 0rOq8QYM8MMtUq+NXd2r8peRsHvrRS7mLErTCZkd5F+Jw26+4tRC1JYm7Ml1tqIto5GO
 DleG+rlLxUqcfLJxFesfV2L7W8gA1wDx8ld57wwj0bb/KV1fO22X5xqvA4R9PM9jnJnx
 r4Xt3X0XtiH81J2KH8rbxFNoQpiUeg6td4EjPStU7pQygNKSAZkDd9AbkWOnY8lEYYxn
 0wXg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1762300483; x=1762905283;
 h=cc:to:subject:message-id:date:from:in-reply-to:references
 :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
 :reply-to;
 bh=RbHu+uwBsQBqJFRYbFeNydYwq6P0LanfKix6KtOp31g=;
 b=JU9EEnn61CDQGMHgrU+sc5bQ44bJH7kyRbReH8GPseRznNmXTomQOUw/l6do/GFlNM
 B6oQkKI8/3qGi+rxYAc1eKd2WV7lW2BcgLdUmy4Z4oKbfAJ9F9Di3LnuZbWEjQXA1wX2
 JOVnCw8Ib29QksrSjiY2dxUelPRC/kw19DLTVHyNqArh8wA3LlrhYAa/6dHn8Vebpiai
 TPWmagC5lUvY28sSV/aq67KzHYe1zdNv/cLHh7WNJXToBxhGtgvsbJyh8A5q9Ch8C8P4
 4RX91Od5RAZSsQsp1a0CEx6k4tIEihrVeZ18frs4K/TH71nIJHlRKNQ63VnEFqSf+3Op
 s4Dg==
X-Forwarded-Encrypted: i=1;
 AJvYcCW5bxMjibsQlo0DvZDjBEsB2c/PRRsAIxH8BmEFYKDmSRUhYTgcrh6qWt/rFrYTy+OuI4zUlTSe/vUQySM=@lists.lustre.org
X-Gm-Message-State: AOJu0Yz75r0y73qmb311aT9tu30ijDPbtyabOXcVIRTcFlUQbCGzrrbx
 rlR34rXyMnsPQdPoUVtNBpaUz2H8MQHxCvYzZdogd7L3GdifA/guZzJj/M6wHoLtIKJTsZHgFn8
 A5rqgaYqKqaovUCu3VxIpL1dXrH+ySMwKhcs1Ja/F
X-Gm-Gg: ASbGncvq+gJ7MvKd5cCfHbZe3dwjypr96RIL46zRp2yNJhuFcKJVJ3P6G6C7MUq0Pgt
 JqTlwAJ1hFJTqYVXpfQouhipyTm4v1Y7W0F0FHqr2ct0OrvCvvqQ8KZiEduuNuQSTn0o17xh+G2
 wpXKWZy4br4OsnZjOnumv0bd4P2V9acpjvu2uzcbLRcNP9ja/R+tYMXyJbgJNNF4/R3naDvD4MA
 3zzB8kTgrm9Yi0Ck+euNV30iVsc0SYMzA6T4SFU7CFeM4SoTBnP4iGtE2OtzX+XViFwxMxLDRAx
 H195WHQipZpV3cQJQkWJS6TSJ/yu
X-Google-Smtp-Source: AGHT+IHEMjSEnlZfK2+f4P+5S+ZS4fjVVhAS8H4xneOI6yoB80NkObTnonPjH1JwIeaKRNXq1gW3e1G7zdG9MkHeq78=
X-Received: by 2002:a05:6808:2116:b0:44f:ec1c:a44 with SMTP id
 5614622812f47-44fed35bda3mr568934b6e.57.1762300482957; Tue, 04 Nov 2025
 15:54:42 -0800 (PST)
MIME-Version: 1.0
References: <85EBE389-4753-454B-9735-B57039CB003A@amazon.com>
 <2AAB29BD-39BB-42E7-B142-45EA006571BD@ddn.com>
 <2820AB7F-9276-40E2-8C51-C62C9304B4B8@dilger.ca>
In-Reply-To: <2820AB7F-9276-40E2-8C51-C62C9304B4B8@dilger.ca>
Date: Tue, 4 Nov 2025 15:54:32 -0800
X-Gm-Features: AWmQ_bnug2f_4IIaVxFuLhLWTle2iEf7UgBPg7TIcpyWaZhm1VwqhnhGw7456Ak
Message-ID: <CAEp8vpi9nRVkBUes8-0RE9YFr7AUPUM+L4AU73UcVU_e6t3ehg@mail.gmail.com>
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
Content-Type: multipart/mixed; boundary="===============6683782866803050681=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============6683782866803050681==
Content-Type: multipart/alternative; boundary="00000000000046f1090642cd8ee1"

--00000000000046f1090642cd8ee1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, Nov 4, 2025 at 3:48=E2=80=AFPM Andreas Dilger <adilger@dilger.ca> w=
rote:

>
> Timothy Day <timday@amazon.com> wrote:
> >>>> I haven=E2=80=99t seen any mention of failover yet in this conversat=
ion (may
> have missed it), but if the device is truly local, then in failed over
> configurations the data is inaccessible.  If it=E2=80=99s *not* local, wh=
y not just
> make the device part of the OST or an independent OST?
> >>>
> >>> It won't be local. Actually, this is designed for the cloud.
> >>
> >> I don't understand how 'local' is being used. Cloud or not, all of the
> >> Lustre client, servers, and backend storage service will be co-located
> >> in the same data center. I think Patrick is asking whether the spill
> >> device will be physically connected to OSS server, or be provided over
> >> something like SAN? Either way, presenting this device as an independe=
nt
> >> OST brings back the pain of manually managing data placement from the
> >> client - which this design is trying to avoid.
> >>
> >>> We already have tiered storage based on mirroring; however, that stil=
l
> requires clients to move data and a file system level scanner to decide
> which files move to the cold tier. It's cumbersome to maintain those
> clients.
> >>
> >> Agree, it's not ideal.
>
> Regardless of how the spill device is implemented, there will need to be
> some scanning of the front OSD device to find/manage objects to mirror
> and release.  This could be done directly on the OST with something like
> DDN's lipe_find3 utility, or older scanners like lester, zester, e2scan,
> etc. that scan the local ldiskfs block device directly.
>
> If the overhead of a local Lustre mount on the OSS is problematic, that
> seems like something which could/should be fixed?  The local mounts are
> already "non-recoverable" so that they do not get an entry in last_rcvd
> and their absence does not cause any recovery issues.
>
> The main issue we've seen with local mountpoints is that this can confuse
> HA and prevent Lustre module unloading if they are not taken into account
> during cleanup.
>

You're right. That's actually why we didn't do it in the first place. If an
OSS crashes, it will definitely lead to recovery timeout and client
eviction.


>
> Cheers, Andreas
>
>
>
>
>
>

--00000000000046f1090642cd8ee1
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><br></div><br><div class=3D"gmail_quote g=
mail_quote_container"><div dir=3D"ltr" class=3D"gmail_attr">On Tue, Nov 4, =
2025 at 3:48=E2=80=AFPM Andreas Dilger &lt;<a href=3D"mailto:adilger@dilger=
.ca">adilger@dilger.ca</a>&gt; wrote:<br></div><blockquote class=3D"gmail_q=
uote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,2=
04);padding-left:1ex"><br>
Timothy Day &lt;<a href=3D"mailto:timday@amazon.com" target=3D"_blank">timd=
ay@amazon.com</a>&gt; wrote:<br>
&gt;&gt;&gt;&gt; I haven=E2=80=99t seen any mention of failover yet in this=
 conversation (may have missed it), but if the device is truly local, then =
in failed over configurations the data is inaccessible.=C2=A0 If it=E2=80=
=99s *not* local, why not just make the device part of the OST or an indepe=
ndent OST?<br>
&gt;&gt;&gt; <br>
&gt;&gt;&gt; It won&#39;t be local. Actually, this is designed for the clou=
d.<br>
&gt;&gt; <br>
&gt;&gt; I don&#39;t understand how &#39;local&#39; is being used. Cloud or=
 not, all of the<br>
&gt;&gt; Lustre client, servers, and backend storage service will be co-loc=
ated<br>
&gt;&gt; in the same data center. I think Patrick is asking whether the spi=
ll<br>
&gt;&gt; device will be physically connected to OSS server, or be provided =
over<br>
&gt;&gt; something like SAN? Either way, presenting this device as an indep=
endent<br>
&gt;&gt; OST brings back the pain of manually managing data placement from =
the<br>
&gt;&gt; client - which this design is trying to avoid.<br>
&gt;&gt; <br>
&gt;&gt;&gt; We already have tiered storage based on mirroring; however, th=
at still requires clients to move data and a file system level scanner to d=
ecide which files move to the cold tier. It&#39;s cumbersome to maintain th=
ose clients.<br>
&gt;&gt; <br>
&gt;&gt; Agree, it&#39;s not ideal.<br>
<br>
Regardless of how the spill device is implemented, there will need to be<br=
>
some scanning of the front OSD device to find/manage objects to mirror<br>
and release.=C2=A0 This could be done directly on the OST with something li=
ke<br>
DDN&#39;s lipe_find3 utility, or older scanners like lester, zester, e2scan=
,<br>
etc. that scan the local ldiskfs block device directly.<br>
<br>
If the overhead of a local Lustre mount on the OSS is problematic, that<br>
seems like something which could/should be fixed?=C2=A0 The local mounts ar=
e<br>
already &quot;non-recoverable&quot; so that they do not get an entry in las=
t_rcvd<br>
and their absence does not cause any recovery issues.<br>
<br>
The main issue we&#39;ve seen with local mountpoints is that this can confu=
se<br>
HA and prevent Lustre module unloading if they are not taken into account<b=
r>
during cleanup.<br></blockquote><div><br></div><div>You&#39;re right. That&=
#39;s actually=C2=A0why we didn&#39;t do it in the first place. If an OSS c=
rashes, it will definitely lead to recovery timeout and client eviction.</d=
iv><div>=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0=
px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">
<br>
Cheers, Andreas<br>
<br>
<br>
<br>
<br>
<br>
</blockquote></div></div>

--00000000000046f1090642cd8ee1--

--===============6683782866803050681==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============6683782866803050681==--

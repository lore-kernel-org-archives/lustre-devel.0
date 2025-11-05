Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id AD3F8CCFA04
	for <lustre-devel@archiver.kernel.org>; Wed,  5 Nov 2025 01:11:32 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4d1Rn44hmYz20dj;
	Tue, 04 Nov 2025 16:59:52 -0800 (PST)
Received: from mail-oa1-f50.google.com (mail-oa1-f50.google.com
 [209.85.160.50])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4d1RmQ12F8z20df
 for <lustre-devel@lists.lustre.org>; Tue, 04 Nov 2025 16:59:18 -0800 (PST)
Received: by mail-oa1-f50.google.com with SMTP id
 586e51a60fabf-3e1175ef97bso602427fac.2
 for <lustre-devel@lists.lustre.org>; Tue, 04 Nov 2025 16:59:18 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=google.com; s=20230601; t=1762304196; x=1762908996; darn=lists.lustre.org;
 h=cc:to:subject:message-id:date:from:in-reply-to:references
 :mime-version:from:to:cc:subject:date:message-id:reply-to;
 bh=N2d08o2T4i8gUWrD2GQBgUISBi8qarVDCqhsdunSrsg=;
 b=g7BZ9IhrPabbQcwhpWHWQrPnV7ClXIvGycYb21kxNZsYxyL7yN3d/9aRbzYGXOu40I
 8OJc0pWM2mGcekHLX5iWf9Alpng84zVnE2cG6GzhnUR6mDHahceQG7hZxmvk/AO2Uw0Q
 UwqfOAnZZi4h/qdgO6cgVaO2yIm8+rCXOASH3SIg+ox5IHCAAuxbQlrkAko5XmUWO25h
 hRLjBUQWHv/kY7H/RzW1K+xUEuI3wLcEn1eKy2S0jjxv1/BQAsnIrGI3GaDa6i5gNKul
 XFOp3D9NdEZzyHY4HE/OnHH50xFZEzorBLB0nbzg7okE2gHfHB4oh4pCEpJ+PQmBQJfz
 7LNw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1762304196; x=1762908996;
 h=cc:to:subject:message-id:date:from:in-reply-to:references
 :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
 :reply-to;
 bh=N2d08o2T4i8gUWrD2GQBgUISBi8qarVDCqhsdunSrsg=;
 b=G4xK82SOSwgR+/7eWJDDDwubfOdx4qX0Fa1mHSlY3iWi1ZaZjKzWBimRgAzIPsnpNi
 ESnzxpfrvIS+udafmZj4Kx64K6r/OWKvSYu/ALujTz3ju2tVJdeISw3tVhxbpQXJB0zK
 SAbWYMQxc3EecsdkI1lItVFrIbUtL7Dkda3IwDOFXeUalSrJoysqBEdE+6qB5tfOdVlI
 IR6XxcVIOdvF4u7Nui+2K7WNrXZ2ldrPSEz02vl39Ath0otXbqj7f2Fllk4GBV8n7F65
 hRYcuLMkPjalhpM5NotGxp0K7knMDXjb1d03keuo1IzPu0yMgSWqWOE+TVNiY45JRgMQ
 jF2Q==
X-Forwarded-Encrypted: i=1;
 AJvYcCUi69/f5Wb5bwfL9XzCRMhW5ev9ilxAXnoFaTsxZ4JYtHH7vYt3oKT/+ErCPZUmwwubKZxneUIl3bDHK9s=@lists.lustre.org
X-Gm-Message-State: AOJu0YzYlvOiv3YHz8b4P2m66VQiV21SirYqGp/aa6dwQggZ/halJAHP
 anQV7wFM55EIjz0nbeP7DgZU1YRzMJOcIrLqBXwxQ2fKZGWVFIf+R2vb36AIBVoUwyklcbv96ju
 jFg/cdWY/2D+j7etuL7L0Eq4kXKhWR4fUpgcqbj1ElW0Bc12GWIY4HxFJPx4=
X-Gm-Gg: ASbGncsMkAp2Qnf+/5SYcKoDDuWMeAIR8bMiFDY7kUL/91kK/CoP0Lvjb/QcZ3ZTfb8
 aSNuit6Z1z7ToEdfwLqPG/quww0RjLzTSeOOpAeNucTKkS9FSdWWIhHY3DTGcDon1S24UduGR1+
 HZ9VtwLWuVLy57nR+azXXG9UzqbJI2HxW/wVzLxvVh7+T6N+l3rQav7xHWXRivPc2VMsjG9oMaB
 D527Q0fVK/xr3HC1tsv+XAAdKqiYq9dFumsp+yMgnzDTJxPH0dVdwlcvBE9lMpXDQoZ7LZuxjtP
 GStIkmcpJsEoCK9G++jmaPkZiP3x
X-Google-Smtp-Source: AGHT+IEXZ87Bu3gpXlVxq4X/e0rqu4Z11cjAR15cKSFONTEKSJoBKegOxByYnh+L6E5t5L5xP7Qvp5f8OTZbMQ0spmk=
X-Received: by 2002:a05:6871:cc86:b0:3dc:b701:cb59 with SMTP id
 586e51a60fabf-3e19b83ba27mr586085fac.46.1762304195949; Tue, 04 Nov 2025
 16:56:35 -0800 (PST)
MIME-Version: 1.0
References: <CFE3C4C8-104E-4F7F-A52E-21B8957FAC0F@amazon.com>
 <0092A54A-6EEF-4CD3-8AFD-7B0066A08810@gmail.com>
 <D8E0F0C0-1A5F-413A-82EA-F3CFA473D2E1@amazon.com>
 <28B74585-1877-4A33-9218-FD50AE72D33D@ddn.com>
 <74326E79-3FCD-41F5-B5DA-95EA2CC48435@gmail.com>
 <A0DE1BFF-A1D4-4104-8333-E6D771F46713@dilger.ca>
 <CAEp8vphfZW4CjgQpCQi6yDBACoTP_3n-5EAFckrOi802_Ajmjw@mail.gmail.com>
 <E296EEC2-800E-4C85-9764-2854D5ED26DD@dilger.ca>
In-Reply-To: <E296EEC2-800E-4C85-9764-2854D5ED26DD@dilger.ca>
Date: Tue, 4 Nov 2025 16:56:25 -0800
X-Gm-Features: AWmQ_bkQI4-q2hIueVEBknZoDCI0ibmCJ8Qmo8DlkD6-7iJ8fik1ClpeP18HZzk
Message-ID: <CAEp8vphD04iwq7rwL_Wg6G-H63U4dhTEVEGzTmOfX+D7CgmZ1A@mail.gmail.com>
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
Content-Type: multipart/mixed; boundary="===============4353154605139319170=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============4353154605139319170==
Content-Type: multipart/alternative; boundary="00000000000096b23b0642ce6b8d"

--00000000000096b23b0642ce6b8d
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, Nov 4, 2025 at 4:46=E2=80=AFPM Andreas Dilger <adilger@dilger.ca> w=
rote:

> On Nov 4, 2025, at 5:28 PM, Jinshan Xiong <jinshanx@google.com> wrote:
> > On Tue, Nov 4, 2025 at 4:20=E2=80=AFPM Andreas Dilger wrote:
> >> I don't see how the layout xattr format is related to filesystem-level
> >> scanning?  This is "just" the xattr format *STORED ON THE OST OBJECT*,
> >> and it could be handled by direct device-level (OST) scan tools as wel=
l.
> >
> > I see. I initially thought you proposed the spill device would function
> as a mirror and that the existing software stack would handle it.
> >
> > Are we going to store the spilled object's status in the layout? It
> sounds difficult because you will have to initiate a layout change from t=
he
> OSTs. I think we still need to store such an xattr locally in the OST
> object.
>
> I'm exactly proposing that the layout xattr be stored on the OST object.
> It would have the same format as the existing Lustre layout stored on
> the MDT, but *maybe* a different name (e.g. "trusted.spl", "trusted.osd",
> or whatever).
>
> I'm not sure if using "trusted.lov" will confuse filesystem scanning
> tools or help them...  It probably makes sense to have a different
> xattr name, just in case we want MDT spilling (e.g. NVRAM->QLC) in
> the future.
>

I would prefer a different name, even though the client likely won't see it
directly. Using the same name for different things will only lead to
confusion. I would go for "trusted.spl".


>
> >> This would allow mirrors (FLR), multiple spill devices (multiple FLR
> >> mirrors), concatenated devices (PFL), etc.  It just avoids adding new
> >> formats that need to be parsed, printed, etc.
>
> Cheers, Andreas
>
>
>
>
>
>

--00000000000096b23b0642ce6b8d
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><br></div><br><div class=3D"gmail_quote g=
mail_quote_container"><div dir=3D"ltr" class=3D"gmail_attr">On Tue, Nov 4, =
2025 at 4:46=E2=80=AFPM Andreas Dilger &lt;<a href=3D"mailto:adilger@dilger=
.ca">adilger@dilger.ca</a>&gt; wrote:<br></div><blockquote class=3D"gmail_q=
uote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,2=
04);padding-left:1ex">On Nov 4, 2025, at 5:28 PM, Jinshan Xiong &lt;<a href=
=3D"mailto:jinshanx@google.com" target=3D"_blank">jinshanx@google.com</a>&g=
t; wrote:<br>
&gt; On Tue, Nov 4, 2025 at 4:20=E2=80=AFPM Andreas Dilger wrote:<br>
&gt;&gt; I don&#39;t see how the layout xattr format is related to filesyst=
em-level<br>
&gt;&gt; scanning?=C2=A0 This is &quot;just&quot; the xattr format *STORED =
ON THE OST OBJECT*,<br>
&gt;&gt; and it could be handled by direct device-level (OST) scan tools as=
 well.<br>
&gt; <br>
&gt; I see. I initially thought you proposed the spill device would functio=
n as a mirror and that the existing software stack would handle it.<br>
&gt; <br>
&gt; Are we going to store the spilled object&#39;s status in the layout? I=
t sounds difficult because you will have to initiate a layout change from t=
he OSTs. I think we still need to store such an xattr locally in the OST ob=
ject.<br>
<br>
I&#39;m exactly proposing that the layout xattr be stored on the OST object=
.<br>
It would have the same format as the existing Lustre layout stored on<br>
the MDT, but *maybe* a different name (e.g. &quot;trusted.spl&quot;, &quot;=
trusted.osd&quot;,<br>
or whatever).<br>
<br>
I&#39;m not sure if using &quot;trusted.lov&quot; will confuse filesystem s=
canning<br>
tools or help them...=C2=A0 It probably makes sense to have a different<br>
xattr name, just in case we want MDT spilling (e.g. NVRAM-&gt;QLC) in<br>
the future.<br></blockquote><div><br></div><div>I would prefer a different =
name, even though the client likely won&#39;t see it directly. Using the sa=
me name for different things will only lead to confusion. I would go for &q=
uot;trusted.spl&quot;.</div><div>=C2=A0</div><blockquote class=3D"gmail_quo=
te" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204=
);padding-left:1ex">
<br>
&gt;&gt; This would allow mirrors (FLR), multiple spill devices (multiple F=
LR<br>
&gt;&gt; mirrors), concatenated devices (PFL), etc.=C2=A0 It just avoids ad=
ding new<br>
&gt;&gt; formats that need to be parsed, printed, etc.<br>
<br>
Cheers, Andreas<br>
<br>
<br>
<br>
<br>
<br>
</blockquote></div></div>

--00000000000096b23b0642ce6b8d--

--===============4353154605139319170==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============4353154605139319170==--

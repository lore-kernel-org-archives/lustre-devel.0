Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 00777C47DD3
	for <lustre-devel@archiver.kernel.org>; Mon, 22 Jan 2024 19:35:50 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4TJgS12Swdz1yDr;
	Mon, 22 Jan 2024 11:35:45 -0800 (PST)
Received: from mail-yb1-f171.google.com (mail-yb1-f171.google.com
 [209.85.219.171])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4TJgRq3Wvsz1yDD
 for <lustre-devel@lists.lustre.org>; Mon, 22 Jan 2024 11:35:35 -0800 (PST)
Received: by mail-yb1-f171.google.com with SMTP id
 3f1490d57ef6-dc227feab99so3311185276.2
 for <lustre-devel@lists.lustre.org>; Mon, 22 Jan 2024 11:35:35 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=aeoncomputing-com.20230601.gappssmtp.com; s=20230601; t=1705952134;
 x=1706556934; darn=lists.lustre.org; 
 h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
 :date:message-id:reply-to;
 bh=6PlYfL4JopKr7EdIrUWY4+4Mo9+t7j0GjEPY8U7xhzI=;
 b=Y3stSQh4/UTYMxzgDbac5jddxfVN14pQq21goqlPf99DhF71o3/yD5ZPtMP/PLw1XV
 MESjhUR9uR7GjDs8ORwaOY0zZlH9vP7kbLPwgcmpyEyPqiwe5kbbmU2GH0Hh0IJXKIME
 9gQGqwuFnaMHB2cVl4gQzbpSTakqWvPVvOtmjY4AgNx0W+zXmE34VY8UnJ8O1LuGSdY/
 BsLPrU5kSNmDFAKyibbdIUNA/+q+euqLvLKzEQXid1akHZU6t1IYIv0i5OIelLXlnLcm
 mRrdAMhIk3cXM5NJrhbBb17SkV29khzvYrJRKfVy/9beyCF/qCNaAdfedO7EOQHI131F
 63HQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1705952134; x=1706556934;
 h=to:subject:message-id:date:from:mime-version:x-gm-message-state
 :from:to:cc:subject:date:message-id:reply-to;
 bh=6PlYfL4JopKr7EdIrUWY4+4Mo9+t7j0GjEPY8U7xhzI=;
 b=As8KC43yLFvdAyDFvWB8u3jbAW8U1kgs6yQBeXEaSNd26c+ohOvwL1+XMx49Kg01zO
 ausWIXCuvrthvRbSDQo165XEYFV5yfY1RCTrdOuKGPrZ9v88wI8hJrs+02zC12VOdHf7
 5VK+LHyxl7lF6PaA92977pUy1xb6LqCASnQM7Lu84x0thUZTwJuh4OgOAtXrKFJbb1nS
 8yDiLHem58i5rrASW6HCG3obyGAr4XnUB+q4xpwNJ2S43dpGUgIT/sQLEZuP0vVdW6TX
 drvv0y38frsoa1yKks1mS9wjgtB+qn7TG8DmskNoNRoml0Bi9+XFQVmg/QnrptGlrzj1
 ZKOg==
X-Gm-Message-State: AOJu0YyIG4yzdEcnfP42Xig1s9gDUlOwNdiU/0CiLDL0GQOdUQzLzV6u
 Pukt1d9hiz5JXIPaMSA6IOkgZg354g0DYplB8mTMSidPSzbUcwi+R1YnejYfk64uTF+rbWQj1Nl
 ngjsFJzX0LFwfjX2lTNAo2MhHnmhO0RdUbIENGGueiCzrujm7Srg=
X-Google-Smtp-Source: AGHT+IGPAsnBURcqZLP7Yvd0KimEY521xb7WGcYGtmoeiQIMzKiUJpLyJn43OrmjWafH85ySRLz6ORiZoS8pxmve2a8=
X-Received: by 2002:a05:6902:2610:b0:da0:442f:988e with SMTP id
 dw16-20020a056902261000b00da0442f988emr2533315ybb.19.1705952134269; Mon, 22
 Jan 2024 11:35:34 -0800 (PST)
MIME-Version: 1.0
From: Jeff Johnson <jeff.johnson@aeoncomputing.com>
Date: Mon, 22 Jan 2024 11:35:23 -0800
Message-ID: <CAFCYAsfNnaLzKZrOTLLOc0S3077reuEWjs0ytJYNHm4+-5R4Sw@mail.gmail.com>
To: lustre-devel@lists.lustre.org
Subject: [lustre-devel] Cannot find documentation or comment blocks
 specifically defining lnet metrics
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
Content-Type: multipart/mixed; boundary="===============1649262764815180910=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============1649262764815180910==
Content-Type: multipart/alternative; boundary="000000000000f7a34a060f8deebd"

--000000000000f7a34a060f8deebd
Content-Type: text/plain; charset="UTF-8"

Greetings all...

I'm modifying a Lustre metrics reporting tool and incorporating lnet
metrics into the data gathered. I dug through all the documentation I could
find and looked through source for comment blocks and didn't find anything
definitive. I'm hoping someone here could clarify. While some metrics are
obvious (*_drop) others I would rather not develop to based on assumptions.

msgs_alloc
msgs_max
rst_alloc
send_count
recv_count
route_count
drop_count
send_length
recv_length
route_length
drop_length

If someone can point me to the document that clearly defines the above I'd
appreciate it, so far I can't find any. As I said I don't want to develop
based on assumptions.

For example, when sampled over a short period of time does...

((X_length / X_count) / # samples) = avg rpc size of X type?

Send, Recv, Route and Drop are fairly clear. Length and Count I am assuming
are just that, n bytes and IOs. msgs_alloc, msgs_max, rst_alloc are less
obvious.

Thanks!

--Jeff

--000000000000f7a34a060f8deebd
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Greetings all...<div><br></div><div>I&#39;m modifying a Lu=
stre metrics reporting tool and incorporating lnet metrics=C2=A0into the da=
ta gathered. I dug through all the documentation I could find and looked th=
rough source for comment blocks and didn&#39;t find anything definitive. I&=
#39;m hoping someone here could clarify. While some metrics are obvious (*_=
drop) others I would rather not develop to based on assumptions.=C2=A0</div=
><div><br></div><div>msgs_alloc<br>msgs_max<br>rst_alloc<br>send_count<br>r=
ecv_count<br>route_count<br>drop_count<br>send_length<br>recv_length<br>rou=
te_length<br>drop_length<br clear=3D"all"><div><br></div><div>If someone ca=
n point me to the document that clearly defines the above I&#39;d appreciat=
e it, so far I can&#39;t find any. As I said I don&#39;t want to develop ba=
sed on assumptions.</div><div><br></div><div>For example, when sampled over=
 a short period of time does...<br></div><div><br></div><div>((X_length / X=
_count) / # samples) =3D avg rpc size of X type?</div><div><br></div><div>S=
end, Recv, Route and Drop are fairly clear. Length and Count I am assuming =
are just that, n bytes and IOs. msgs_alloc, msgs_max, rst_alloc are less ob=
vious.</div><div><br></div><div>Thanks!</div><div><br></div><div>--Jeff</di=
v><br></div></div>

--000000000000f7a34a060f8deebd--

--===============1649262764815180910==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============1649262764815180910==--

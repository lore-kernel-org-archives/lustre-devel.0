Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 61205C27C53
	for <lustre-devel@archiver.kernel.org>; Wed, 12 Jun 2024 18:36:00 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4VzvPN6YL1z1yCS;
	Wed, 12 Jun 2024 11:35:52 -0700 (PDT)
Received: from mail-yb1-f176.google.com (mail-yb1-f176.google.com
 [209.85.219.176])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4VzvPL5hySz1wSM
 for <lustre-devel@lists.lustre.org>; Wed, 12 Jun 2024 11:35:50 -0700 (PDT)
Received: by mail-yb1-f176.google.com with SMTP id
 3f1490d57ef6-dfe3f7402e6so168608276.3
 for <lustre-devel@lists.lustre.org>; Wed, 12 Jun 2024 11:35:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=charlotte.edu; s=google; t=1718217350; x=1718822150; darn=lists.lustre.org; 
 h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
 :date:message-id:reply-to;
 bh=le0OcRDuiVmDoy71Jg8q2cxr8MTSRiDn4WIwk5gJL0o=;
 b=cFsykEXti8ehLxGb8CQAO4nu+peB07QtOxnqmOW346HyAPOXe69Kpy9ftb10raQtgW
 v4XJQFDplczIsYyryYOJINmcK5a6vLMQWOuL9Rbt+rEhdxufh0Jxwv133ABUEkSGX2nJ
 /W8bCJjU3KWIti2RYx6n5uyAG9yfiGT7/Hhdt/efuySLzU4/xSVetUI6T5ME9VUv3CHT
 /ILeBpfj1c7olQNcWrkfpkGD4w+PlOSfDBOFJoqbV2cqzj5sBLtzCf4q7NST6J3oXY8/
 rxpzQE9n/fKFOAHjrchvBHkMezI3omGPsNgfkK45Om0/lqOtn6pCM+Du4II39tD6euHf
 /dDg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1718217350; x=1718822150;
 h=to:subject:message-id:date:from:mime-version:x-gm-message-state
 :from:to:cc:subject:date:message-id:reply-to;
 bh=le0OcRDuiVmDoy71Jg8q2cxr8MTSRiDn4WIwk5gJL0o=;
 b=iN9HttE0TWgJYZfM51SrrTCQAiYt4XYa8nk/qAkmPmqfxXSPEw6Wzf0gfsRjw7gIPE
 hcL59PXdsn/KevnsMUDcmUaEV4yWyg36LLzbHcr3vZaG0o7+hC/qyANhtAKRpxi6aQO5
 eWK5CMKnx+KeRza6ESxOS9vYqgnUt5DXVqnilaGAhd7mNNeQZf6RR8UBn+R0jgL0fKxC
 qWwc0m58TIyjJJYns/TT4wR9zB6SUZX3cLzLDhGVT0edMVmOsfl8PDJW1tHQvclu+e/d
 N09CxkUfk57zYI25G51LN2eZc764IGq8hnONjZCEf3j0lIFP5bzEkJgVc+VVBpRCIzVP
 nW1A==
X-Gm-Message-State: AOJu0Yytxd5vHb0gwmlnxOgiIH8i2EjNsPiQIlo5cG80lGU+FK9aiQYZ
 7wO3og/RFsail29R9RhB7YnYQkCYZ/1ccHcaM9K4teXqwmIfhbF0iUXJ2R5c79PflfvjNwXhuRx
 a6uXzleBm3qpxaoDscdKeGtW6wQLlQVi6YKOdSd3xnMRzkMaQDSg=
X-Google-Smtp-Source: AGHT+IF/B3p+zTFL81635lnS5QCC90lSHaPzWEA2SSUc4QPeSUCMJXs3XqUqwqnmi7nYKlngcE8sXnKb+vb6nKrXXAU=
X-Received: by 2002:a5b:907:0:b0:dfb:d69:5657 with SMTP id
 3f1490d57ef6-dfe65e7f3b5mr2310799276.9.1718217349672; 
 Wed, 12 Jun 2024 11:35:49 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 12 Jun 2024 14:35:39 -0400
Message-ID: <CACyzrcS7iBzxmzUqLY7vo0gE_=D3v+33HZ_gGeYe6rgkv0YYOg@mail.gmail.com>
To: lustre-devel@lists.lustre.org
Subject: [lustre-devel] Inquiry Regarding Checksum Support for Lustre
 Extended Attributes
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
From: Saisha Kamat via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Saisha Kamat <skamat1@charlotte.edu>
Content-Type: multipart/mixed; boundary="===============0258105027301567297=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============0258105027301567297==
Content-Type: multipart/alternative; boundary="000000000000c646ab061ab5a660"

--000000000000c646ab061ab5a660
Content-Type: text/plain; charset="UTF-8"

Hello,

I hope this email finds you well.

My name is Saisha, and I am currently pursuing my Ph.D. at UNC-Charlotte,
with a focus on research related to the Lustre File System. As part of my
project, I am exploring the possibility of utilizing checksums to verify
Lustre extended attributes.

My understanding is that the ext4 file system supports checksums for
extended attributes (xattrs). However, I am interested in whether this
functionality extends to Lustre as well.

I would greatly appreciate it if you could provide some insights or direct
me to relevant documentation on this matter. Any information or guidance
you can offer would be invaluable to my research.

Thank you very much for your time and assistance.

Thanks and Regards,
Saisha

--000000000000c646ab061ab5a660
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hello,<br><br>I hope this email finds you well.<br><br>My =
name is Saisha, and I am currently pursuing my Ph.D. at UNC-Charlotte, with=
 a focus on research related to the Lustre File System. As part of my proje=
ct, I am exploring the possibility of utilizing checksums to verify Lustre =
extended attributes.<br><br>My understanding is that the ext4 file system s=
upports checksums for extended attributes (xattrs). However, I am intereste=
d in whether this functionality extends to Lustre as well.<br><br>I would g=
reatly appreciate it if you could provide some insights or direct me to rel=
evant documentation on this matter. Any information or guidance you can off=
er would be invaluable to my research.<br><br>Thank you very much for your =
time and assistance.<div><br></div><div>Thanks and Regards,</div><div>Saish=
a</div></div>

--000000000000c646ab061ab5a660--

--===============0258105027301567297==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============0258105027301567297==--

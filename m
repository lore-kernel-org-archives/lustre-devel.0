Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id B6FBBC369DC
	for <lustre-devel@archiver.kernel.org>; Tue, 29 Apr 2025 23:41:43 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZnH054pkdz1xdm;
	Tue, 29 Apr 2025 16:41:41 -0700 (PDT)
Received: from mail-ot1-f42.google.com (mail-ot1-f42.google.com
 [209.85.210.42])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZnGzq2q8Bz1xdN
 for <lustre-devel@lists.lustre.org>; Tue, 29 Apr 2025 16:41:27 -0700 (PDT)
Received: by mail-ot1-f42.google.com with SMTP id
 46e09a7af769-72bd5f25ea6so1739780a34.1
 for <lustre-devel@lists.lustre.org>; Tue, 29 Apr 2025 16:41:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1745970086; x=1746574886; darn=lists.lustre.org;
 h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
 :date:message-id:reply-to;
 bh=SgBr90JG7mmtGbp3NTpOOtFlsQCaFQ6C8Y1cJ+zlm7g=;
 b=dYsmcaMsYT8OSmBlYpOTAXFkGUfP+lPjLHzeWSmati0kz52qPRUHQW6h6LUvKEtaHC
 emDg3yHirWNmbsmJdTWcAVMe2nCXrHmj8xkFGEyUKA+tplUoso2h5A7ugbrfCpi6eWkO
 ow14vbLQ32jME80CgvoEhiFVO9R9O0RsG/Lkh6U3+9B4HG0NwTLBWlEC8VzmQXZrwk4Y
 gr2AG+Dr1RK0Mt3YBc4NiX8eJMvSTXowoPniwjQquUZIaFIrJkVWM6DCDBIDxkExgoIO
 9UOCKzkR5N72ynIE51uwY4OsIK0xKOO/8tGeLZGtNuFRSbk0+pOglGKf8Mmiokc0p2fd
 /Lug==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1745970086; x=1746574886;
 h=to:subject:message-id:date:from:mime-version:x-gm-message-state
 :from:to:cc:subject:date:message-id:reply-to;
 bh=SgBr90JG7mmtGbp3NTpOOtFlsQCaFQ6C8Y1cJ+zlm7g=;
 b=fMareZdwefi1wrEvibklk8nEaPL66fQDsOAXEwnAR8+ntq1ho4Nx7gPCTahifuZIBx
 zur+hZN5pXOMTzrenDuwPFeigdXlhAr+oNPq1E+r4Q2f4zBoUncJRW01SqYqNEpcAabx
 2U9vjDBAb6YNeFEpa1hMxgVVB5a/t5yUXomoDKBHq/Xc2j9iiQ293ALw/1qBOTaI7PuA
 IuUghbArOXWk5fRM9NVXxywOHI8is73uyouzijkHi3pw22VkJWthEmGxV/FZ0m/4+9Fr
 s0qKn1YVm3WabDaNCOGpAhjwpyakHylsaiYNMVgOJI8ahtM4LApqcHOj9N/xAKQqyFAJ
 uNrA==
X-Gm-Message-State: AOJu0YyESb/s5oxHdhOc+er7aOS6+zglQTGcyLvA5/PYJYHJ5VrXCkM9
 AwcTeUh9mYxOvv0QZqjX8R3OzBgZqG6hkG4DDegg0b6SClGqxrJrDBYZl4jTMn1fdxuhJwTzyE/
 bN+rpdVFLNzNntUTfZQgEKohnEDPxpQSi
X-Gm-Gg: ASbGncvCJ1O9LtaggLJMpRprBZMS8SOpvRpcRyJO9hrDJlIePlcstS61ITbLJ3dnGxq
 uuMc34PlvqbeDZ8Xcq79IhTPfJqXNrCuMQvb0KLXTfiVRWPK7WcyRI+rKjCS06LHQJcDDndjIXK
 7UJPAFo9FHDZD9zX97Rd+obA==
X-Google-Smtp-Source: AGHT+IEyHjQX80L5MQ0I8QMlQAbClcwjzhx37J+h5oB8jPO3HKPVk1z1NOlVL06WXqfGFgPERrbzRKevC1o/Nb/DEMg=
X-Received: by 2002:a05:6870:6191:b0:2d9:8578:9478 with SMTP id
 586e51a60fabf-2da6cd04f1emr334730fac.4.1745970085925; Tue, 29 Apr 2025
 16:41:25 -0700 (PDT)
MIME-Version: 1.0
From: GEORGE ZHAO <georgezhaojobs@gmail.com>
Date: Tue, 29 Apr 2025 19:41:12 -0400
X-Gm-Features: ATxdqUHZm2KlctRu94t-z4whz166DA2uUu9jxSmHrogYyhvHkFgIATyTW_qUEXY
Message-ID: <CAFhHJgkiiieEWpva9wtgNzr1iWbbc494BWxK9=9sqdEVkHhTHA@mail.gmail.com>
To: lustre-devel@lists.lustre.org
Subject: [lustre-devel] =?utf-8?q?New_contributor_inquiry_=E2=80=93_statu?=
	=?utf-8?q?s_of_LU-1643_=28=E2=80=9Creserved_space=E2=80=9D_in_stat?=
	=?utf-8?q?fs/df=29_and_guidance_requested?=
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
Content-Type: multipart/mixed; boundary="===============2265324266302160502=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============2265324266302160502==
Content-Type: multipart/alternative; boundary="000000000000c2997d0633f3567a"

--000000000000c2997d0633f3567a
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Folks ,

I'm a storage engineer and a Lustre beginner who just figured out how to
deploy it. Did read a lot about it though.
My goal is using Lustre to support HPC/ML workload. And I believe doing
some tasks would help me proceed better.

As wiki suggested, I found an "easy" ticket LU-1643: =E2=80=9CRequest to re=
move
display of reserved space from statfs (df) total space.=E2=80=9D
Is it still unclaimed?
If it's already in progress, or there's a higher priority issue that could
use help, please point me in the right direction.

Thanks in advance for any advice.

Best regards,
George

--000000000000c2997d0633f3567a
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi Folks ,<div><br></div><div>I&#39;m a storage engineer a=
nd a Lustre=C2=A0beginner who just figured out how to deploy it. Did read a=
 lot about it though.</div><div>My goal is using Lustre to support=C2=A0HPC=
/ML workload. And I believe doing some tasks would help me proceed better.<=
/div><div><br></div><div>As wiki suggested, I found an &quot;easy&quot; tic=
ket LU-1643: =E2=80=9CRequest to remove display of reserved space from stat=
fs (df) total space.=E2=80=9D</div><div>Is it still unclaimed?=C2=A0</div><=
div>If it&#39;s already in progress, or there&#39;s a higher priority issue=
 that could use help, please point me in the right direction.</div><div><br=
></div><div>Thanks in advance for any advice.<br><br>Best regards,</div><di=
v>George</div></div>

--000000000000c2997d0633f3567a--

--===============2265324266302160502==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============2265324266302160502==--

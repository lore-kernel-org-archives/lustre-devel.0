Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 9CF64C27C4F
	for <lustre-devel@archiver.kernel.org>; Tue, 11 Jun 2024 01:46:21 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Vys0c4wmpz219T;
	Mon, 10 Jun 2024 18:44:16 -0700 (PDT)
Received: from mail-pg1-f181.google.com (mail-pg1-f181.google.com
 [209.85.215.181])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Vyr8g0JLlz1wL2
 for <lustre-devel@lists.lustre.org>; Mon, 10 Jun 2024 18:06:11 -0700 (PDT)
Received: by mail-pg1-f181.google.com with SMTP id
 41be03b00d2f7-6e620302b01so2067036a12.0
 for <lustre-devel@lists.lustre.org>; Mon, 10 Jun 2024 18:06:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1718067970; x=1718672770; darn=lists.lustre.org;
 h=cc:to:subject:message-id:date:from:mime-version:from:to:cc:subject
 :date:message-id:reply-to;
 bh=P3KelNTsHMxHTMQKW6dYEwZzJKS27SUI9IY68+4m91k=;
 b=HEdTavEGZzlkOdZQI9oeDLdfbEkjkduN6b2D0KYFeGeQQMJqipYNLOJZgtsuiy49yG
 X8NvVfM7V6zOAzufJj+IcJu4XZ4Q+J3sYKnJh5uSNd9Fs9/F4HqBpkkq9v9N84wGO4W5
 8bl5Cl1/dai/HRfMRlX+MHFrkgh/fpmzN9paP3p+f44r0j4fVq8An1KcpadEg5QVpCtA
 FUSJJCah/Q4c9gr00D5WtTs/DfP8qGc+s4CHtL/wdAAcUZHeBhP13gkN3M29YArHm9fJ
 L6ectlFmjS9E4vDmptlX1mhrjDQbxnOPBCSGe48TeyQQ7+4YKcHhg239wX3BgcrfW157
 LmFQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1718067970; x=1718672770;
 h=cc:to:subject:message-id:date:from:mime-version:x-gm-message-state
 :from:to:cc:subject:date:message-id:reply-to;
 bh=P3KelNTsHMxHTMQKW6dYEwZzJKS27SUI9IY68+4m91k=;
 b=w8ypcwP7MbapoKZN+o9TCb+jvVxzg22COU7eEJTrrhSHY3vi/52pCD0lOG5tzfsJNf
 Mk8VfM7DxiIb65OvDdKmF1Mta8lwJFI2VdvORvywCr6EfUaztShxhZlX/D4AMoxsq8UR
 bX8hfa5+xnN36EeazC3ohqOxQ9KKtdpBKGzQFLBrfmuDRYXObQ0Kz/vU3rwLAmbeFYEi
 vEY+G0k0s5u1LqrrSHwNR4JpiN65058PP/MNQUwuXtyFGlEsPW+8CevM4RRAr/4PgLfX
 t0BrRzloNsahBKFI+9n0yjzSD7p7gyFVK0bSnmD56KsVJOX7xxc1ndI4ZQCkofN+uwOZ
 GGMg==
X-Gm-Message-State: AOJu0YwlbgpSsl8fAiTaGW9GjGnvOIYAtloL7WIwovvxC4Qjsjqe/V9e
 zXt1HaP/7ipKqJFLD48Aq8h8JR/DXCG3ni1NrlommC84hkT5qDw0r8hdMvYYfIrxBTdxGJWpJYS
 3sU4w0MBbanKfBu1hnmmlGBxVmYOrYwP+
X-Google-Smtp-Source: AGHT+IEdzi/VRNQQwuDUL+heU6PKEdZDz4owK5xFtfLbIloxuuQOSgkh9OvRZtxzJq7jn2sTuurQlRFyDAkPY9t2UwM=
X-Received: by 2002:a05:6a20:7f99:b0:1b2:1ae6:2ccc with SMTP id
 adf61e73a8af0-1b2f96a367bmr10729703637.7.1718067969858; Mon, 10 Jun 2024
 18:06:09 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 10 Jun 2024 21:05:33 -0400
Message-ID: <CAGfFL-xAZf7-cL3iGaxL16Gh4L_bZvNZbUq42LGE2HdNs15z-Q@mail.gmail.com>
To: Lustre Developement <lustre-devel@lists.lustre.org>
Cc: Raju Rangaswami <rangaswami@gmail.com>, Hongpeng Jin <hjin008@fiu.edu>,
 Yanzhao Wu <yawu@fiu.edu>
X-Mailman-Approved-At: Mon, 10 Jun 2024 18:43:42 -0700
Subject: [lustre-devel] Survey request to help with LLM development for
 Lustre
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
From: John Bent via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: John Bent <johnbent@gmail.com>
Content-Type: multipart/mixed; boundary="===============9032826810173751182=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============9032826810173751182==
Content-Type: multipart/alternative; boundary="0000000000000b28bc061a92dfef"

--0000000000000b28bc061a92dfef
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Dear Lustre Community Members,

 We hope this message finds you well.

We are a research team from FIU and LANL. Following up on my recent talk at
last month=E2=80=99s Lustre User Group (LUG) meeting (LINK
<https://www.depts.ttu.edu/hpcc/events/LUG24/slides/Day2/LUG_2024_Talk_09-T=
ASSI_John_Bent_LUG24.pdf>),
we are reaching out to invite you to participate in a survey to evaluate
the accuracy of Large Language Models (LLMs) in answering questions about
Lustre. Your expertise and experience are crucial for assessing how well
LLMs compare to human experts within our community.

Here are the details of the survey:

   - Number of Questions: 10
   - Estimated Completion Time: 15 ~ 30 minutes
   - Link: https://forms.gle/MHEf2FBYTjyRioa16

Note: We very much appreciate your time and contribution! Although it would
be wonderful if all of you are able to answer all ten questions, we realize
that this is a very large request. If you are able to help, please try to
respond to at least 3 questions and feel free to select the option =E2=80=
=9CI
prefer not to answer=E2=80=9D for the others.

In  this work, our ultimate goal is to improve the ability of local LLMs to
help administrators, users, and developers of Lustre. We will publish the
anonymized results of this survey back to this mailing list and hope to
publish research results in peer-reviewed conferences as well as report
back on our progress at future LUGs. Additionally, our work with local LLMs
will be done in open source. Finally, we recognize that LLMs are evolving
rapidly so we plan to repeat this exercise with other systems such as Ceph
as well as repeating this exercise at some point in the future with Lustre.
We hope to present results at a future LUG. Although, no future LUG could
ever surpass the awesome one just organized by the great folks at Texas
Tech, we know that they are all pretty great. :)

Thank you for your time and dedication to the Lustre community. Your
insights are invaluable, and we eagerly await your input.

In addition to the survey, we welcome any and all feedback on this specific
exercise as well as our research in general.

Thanks,

Hohnpeng, John, Raju, and Yanzhao

--0000000000000b28bc061a92dfef
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Dear Lustre Community Members,<br><br>=C2=A0We=C2=A0hope t=
his message finds you well.<br><br>We are a research team from FIU and LANL=
. Following up on my recent talk at last month=E2=80=99s Lustre User Group =
(LUG) meeting (<a href=3D"https://www.depts.ttu.edu/hpcc/events/LUG24/slide=
s/Day2/LUG_2024_Talk_09-TASSI_John_Bent_LUG24.pdf">LINK</a>), we are reachi=
ng out to invite you to participate in a survey to evaluate the accuracy of=
 Large Language Models (LLMs) in answering questions about Lustre. Your exp=
ertise and experience are crucial for assessing how well LLMs compare to hu=
man experts within our community.<br><br><div>Here are the details of the s=
urvey:<br><ul><li>Number of Questions: 10</li><li>Estimated Completion Time=
: 15 ~ 30 minutes</li><li>Link: <a href=3D"https://forms.gle/MHEf2FBYTjyRio=
a16">https://forms.gle/MHEf2FBYTjyRioa16</a></li></ul></div><div>Note: We v=
ery much appreciate your time and contribution! Although it would be wonder=
ful if all of you are able to answer all ten questions, we realize that thi=
s is a very large request. If you are able to help, please try to respond t=
o at least 3 questions and feel free to select=C2=A0the option =E2=80=9CI p=
refer not to answer=E2=80=9D for the others.<br><br>In =C2=A0this work, our=
 ultimate goal is to improve the ability of local LLMs to help administrato=
rs, users, and developers of Lustre. We will publish the anonymized results=
 of this survey back to this mailing list and hope to publish research resu=
lts in peer-reviewed conferences as well as report back on our progress at =
future LUGs. Additionally, our work with local LLMs will be done in open so=
urce. Finally, we recognize that LLMs are evolving rapidly so we plan to re=
peat this exercise with other systems such as Ceph as well as repeating thi=
s exercise at some point in the future with Lustre. We hope to present resu=
lts at a future LUG. Although, no future LUG could ever surpass the awesome=
 one just organized by the great folks at Texas Tech, we know that they are=
 all pretty great. :)<br><br></div><div>Thank you for your time and dedicat=
ion to the Lustre community. Your insights are invaluable, and we eagerly a=
wait your input.<br></div><div><br></div><div>In addition to the survey, we=
 welcome any and all feedback on this specific exercise as well as our rese=
arch in general.</div><div><br></div><div>Thanks,</div><div><br></div><div>=
Hohnpeng, John, Raju, and=C2=A0Yanzhao</div></div>

--0000000000000b28bc061a92dfef--

--===============9032826810173751182==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============9032826810173751182==--

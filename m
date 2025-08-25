Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 92204CA0FE7
	for <lustre-devel@archiver.kernel.org>; Mon, 25 Aug 2025 16:01:26 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4c9bBV53cwz1xM5;
	Mon, 25 Aug 2025 09:01:22 -0700 (PDT)
Received: from mail-vk1-f177.google.com (mail-vk1-f177.google.com
 [209.85.221.177])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4c9Tzz6bq7z1wcN
 for <lustre-devel@lists.lustre.org>; Mon, 25 Aug 2025 05:06:55 -0700 (PDT)
Received: by mail-vk1-f177.google.com with SMTP id
 71dfb90a1353d-53b16f90e51so3259277e0c.0
 for <lustre-devel@lists.lustre.org>; Mon, 25 Aug 2025 05:06:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1756123614; x=1756728414; darn=lists.lustre.org;
 h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
 :date:message-id:reply-to;
 bh=uiBFylF45wYFhf4xCL64SiCK8BLQhwhnAOzwxNlomuA=;
 b=GgKsgg55poY5YxyG/7u+CbNVFEB2mUqSNvOoxb5ug72KXGGLaE3KxIXP1SproDud3d
 +38mPoUNUNmt6zBPzvcVmz5YIVF9gH8rPzmcGfm56CYMCYbDGTaMnGPj6xYDPqCF0jRX
 r/DhgyGmgviNQ4JjO3wLb5OHpHtULprduyZoJnR5O+kQNJiugEmLHw7bwPYm3rRpXz+M
 BKyPRImvQgJhgz6ZDYLE9zPms9nDgsePbBia+PCA7C8p0TPW6QBWhH1ELvrM4FbG8PRa
 WFmBpnXbCNzIWH2iOUYzQYHIhvaHLmSfsfQuSjpnTPauVXXyd85dvoYzhAyDpnHa/Cv5
 fUoA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1756123614; x=1756728414;
 h=to:subject:message-id:date:from:mime-version:x-gm-message-state
 :from:to:cc:subject:date:message-id:reply-to;
 bh=uiBFylF45wYFhf4xCL64SiCK8BLQhwhnAOzwxNlomuA=;
 b=h7YOyOkpJr6be4n7iigHu2XhphfAHNSjt5k8ftaCKYjlFqfJzuJbhgkZT7UhwBhHts
 t4eRBlhHw6ELoP8jAu/VRqDyVq2WpvnlqzV51FV4chznbTvUZAuChyw0X1vGFb0WI/pl
 QkiOS0MV5i7rGXwMKR0vpNd3bZRSfi8EXyn5YqqYu84N8BBAXJwjhJWyo4cVPEHxgBh4
 Ak/CbNVHY+JS8YUANRIJ9d2XdMAWXnYIed0A6oWnvhtbAfE9O5AtekO6i0hjE6Ujc09T
 brXb+Lhyh/8e6wfxWLHW08Rb7JGgv7F/MQw1lv8s7v6dFuhNC28gaGKOfy7drwFSwvnT
 xMeg==
X-Gm-Message-State: AOJu0YzxovHW4zZ8KniC0DjRkVqezTUeVNQaGxg1ksLI1gA6lMsKOaJm
 ckaTXgGA7BdpMcqZlLV1Z600sJ2W4Abfo/Hp/c1UQLGkMXtMGCFBifmpPdk7SiLDYf/kQrg36Nk
 nO8X8RgP8q7GDc/9Z+miJRhjGhQHxfyZjFCMb
X-Gm-Gg: ASbGncup2wAxw52XksicDX3Y5zvsAmRrWUHgYYoXTHmhdjk55JLTMc3IGSSFmMWR2KO
 8n5y27T+P+3nTVkvVnSdb0Wkyv/kA8IWQzsMSev7poP3JFjTTG5vDBrQbeOuy6glJMtKsUtHZqC
 0XOVVU5hPfQCIQHwoUWPjmdgvcOCIdgiYKQETSjnFm5LDhyoU3yiuXt/JzuNIBcjd62Djy+XIJo
 Py6eUy8m7Ig0Ubsgbn+iR15nUlsDoe6IaSd+ZrA
X-Google-Smtp-Source: AGHT+IHp2nxjCJRzFTV5GR9pSUEXYLatQsZT6MHSZMsAj9IYp+5kCqEaoLiv6ByOyDdH+Y8CmJ/YqqS8XxE9FryTwLo=
X-Received: by 2002:a05:6122:6c0a:b0:53b:fb9:6fd3 with SMTP id
 71dfb90a1353d-53c7d6bfdecmr4649569e0c.7.1756123614192; Mon, 25 Aug 2025
 05:06:54 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 25 Aug 2025 14:06:43 +0200
X-Gm-Features: Ac12FXwHmCXfMdsZ54qhznX6XYH37H5pdqrXz8vFg_-e5tQHJiuSV0n6FYr0_zM
Message-ID: <CACd6u-qfd=cyJBEmM7TwWM=++AMT8KmVu=97EX24jiukzDPJRA@mail.gmail.com>
To: lustre-devel@lists.lustre.org
X-Mailman-Approved-At: Mon, 25 Aug 2025 09:01:18 -0700
Subject: [lustre-devel] Git server down?
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
From: =?utf-8?q?G=C3=B6tz_Waschk_via_lustre-devel?=
 <lustre-devel@lists.lustre.org>
Reply-To: =?UTF-8?B?R8O2dHogV2FzY2hr?= <goetz.waschk@gmail.com>
Content-Type: multipart/mixed; boundary="===============3312138425721967489=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============3312138425721967489==
Content-Type: multipart/alternative; boundary="00000000000034a77a063d2f64a9"

--00000000000034a77a063d2f64a9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi everyone,

I cannot access the git server:

# git clone -b master git://git.whamcloud.com/fs/lustre-release.git
lustre-master
Cloning into 'lustre-master'...
fatal: unable to connect to git.whamcloud.com:
git.whamcloud.com[0: 2606:4700:3031::6815:30f6]: errno=3DConnection timed o=
ut
git.whamcloud.com[1: 2606:4700:3030::ac43:8af5]: errno=3DConnection timed o=
ut
git.whamcloud.com[2: 104.21.48.246]: errno=3DConnection timed out
git.whamcloud.com[3: 172.67.138.245]: errno=3DConnection timed out

Regards,
G=C3=B6tz Waschk

--00000000000034a77a063d2f64a9
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi everyone,<div><br></div><div>I cannot access the git se=
rver:</div><div><br></div><div># git clone -b master git://<a href=3D"http:=
//git.whamcloud.com/fs/lustre-release.git">git.whamcloud.com/fs/lustre-rele=
ase.git</a> lustre-master</div><div>Cloning into &#39;lustre-master&#39;...=
<br>fatal: unable to connect to <a href=3D"http://git.whamcloud.com">git.wh=
amcloud.com</a>:<br><a href=3D"http://git.whamcloud.com">git.whamcloud.com<=
/a>[0: 2606:4700:3031::6815:30f6]: errno=3DConnection timed out<br><a href=
=3D"http://git.whamcloud.com">git.whamcloud.com</a>[1: 2606:4700:3030::ac43=
:8af5]: errno=3DConnection timed out<br><a href=3D"http://git.whamcloud.com=
">git.whamcloud.com</a>[2: 104.21.48.246]: errno=3DConnection timed out<br>=
<a href=3D"http://git.whamcloud.com">git.whamcloud.com</a>[3: 172.67.138.24=
5]: errno=3DConnection timed out<br></div><div><br></div><div>Regards,</div=
><div>G=C3=B6tz Waschk</div></div>

--00000000000034a77a063d2f64a9--

--===============3312138425721967489==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============3312138425721967489==--

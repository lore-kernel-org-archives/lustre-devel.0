Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 04C6EF41986
	for <lustre-devel@archiver.kernel.org>; Wed, 15 Apr 2026 10:05:41 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4fwcGB0M88z23SJ;
	Wed, 15 Apr 2026 03:05:22 -0700 (PDT)
Received: from mail-ot1-f52.google.com (mail-ot1-f52.google.com
 [209.85.210.52])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4fwcG5300vz23Mr
 for <lustre-devel@lists.lustre.org>; Wed, 15 Apr 2026 03:05:17 -0700 (PDT)
Received: by mail-ot1-f52.google.com with SMTP id
 46e09a7af769-7dbe07d3ec3so3200229a34.0
 for <lustre-devel@lists.lustre.org>; Wed, 15 Apr 2026 03:05:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1776247516; cv=none;
 d=google.com; s=arc-20240605;
 b=iOXUgcAkfSZygt9UnnxbdQUJRry6lMPZY4GFJqD6lUGZeI6vV5sLP2hKvNtV789By1
 5pA80Wbl74uTLZnTfK1qwirv/eIntrxXt22O/F4pXrZEKHtOMI5QD4oYWUL+zSIKzQu4
 eJKPgdEkaUQ2g3pVzm5unLzUUFqQBz1W3DwTUzZ9idyx7l+U3Q5M3k7+MJhrJbv4oP7M
 Sjj7CZGXdmnZO96J/a/k0PHQ9QKwdgVD7nTzS0+e43g9aoA9canwO/WW16jUbuP1h4tu
 JsJ7Wv1fVbFaEXiBJsMwOph3YUQDF1H/KmknaHcO2Ydjk0BGVpIzt3WJHWqSSMxg1jWA
 5Uww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com;
 s=arc-20240605; 
 h=to:subject:message-id:date:from:mime-version:dkim-signature;
 bh=gvw2O2ygkF0OCEDE1Ulv+ZSysWVDP3iyh832CAXOF4I=;
 fh=B2Dx0/EI/14h2hZDpTTsDj/GsNer2lhP02snZelGrkk=;
 b=F4B18XwbYCXOlF5Vg8XV2EXHn7i1WSgSgaiG/lZrs54MIR9B+BkhUlEHJXGQbLqH/9
 NybQjlqf+vYaPCD80Y8l7Z3tb7vCAfUgtWFCROUoDOl5fVXaree1jqMglzDZftLLZ5HZ
 8+nz6gsfIe/1YrIGDl8J+10nEmxoWoQy9OlcYTNmf7mJ/WKaTI2lidIxoyCRN1fOUI+9
 ryQI/tATWsIsRWCr7csO3WvvtHftF7x4tfiKo1srpZrrC9t9K2oAZ0xrGmJ2rN7dk0w9
 b4F/KuyZmBl3NxxI9x8jNBfZCRNxuq3Y6QHOujDVLp71bahPcXb1Atp5IGoLkEfJUU7A
 s/KQ==; darn=lists.lustre.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20251104; t=1776247516; x=1776852316; darn=lists.lustre.org;
 h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
 :date:message-id:reply-to;
 bh=gvw2O2ygkF0OCEDE1Ulv+ZSysWVDP3iyh832CAXOF4I=;
 b=Uy6h8gw8IYngXYIxy1Y/FP15RMGrqslFC2ApGwZKuwu+I4aIqBB77nOcJtPnV8GQuX
 NFWt0Aa2dGtqrLIYaRyZkM3O7rxqVqJAaJP94dRxjenlyyNsCpsKgw+L/spNvlKumC0+
 clKnFIVuxfodkJEGw2z2BaQfesGiXBvcJ+4YKwdTNYVdNA4BEjoxDVI5ojG8jtseMfhi
 ktU9c7QYolSQnciHLZBrMtE1uly4MNUEJhkNpUY5kvQV0202o7TyzmK/C7ohK6ohIYE3
 xQPOZHjJIun0Fr1mfGxiOKx+mHSN/9Isy54dfE3OoKqKeLTsksPe7AANY79+sXBfS8+e
 m1+A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20251104; t=1776247516; x=1776852316;
 h=to:subject:message-id:date:from:mime-version:x-gm-gg
 :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
 bh=gvw2O2ygkF0OCEDE1Ulv+ZSysWVDP3iyh832CAXOF4I=;
 b=dbi7AqV9mg6A6Qf65I5z4Qn1KdQcIJl5RaJll8GMK9zIifw2CndoOC7YCaLFsCCvQ3
 cfzuAugIy91t0nDROSzSS+zyAzZ14Y6rpF/T1ggc3pkseuzA4Z49Hvxkfy4w37G9hTcK
 aVog15H2eVmJedLlDR1LX1UqI2XKus8w5wRP0YKqTpJ9k3No7x8PHz9gtZ8pMffNO5Lm
 By81mvuB9R4J2WI//drax6OXVrlC6GVKktHXCJ4FQR/uAMU8x7Ukc9hFgKS1sVF4m3v7
 61lG+PWHtF6i0tnnKgisj27H2Hr3x08LwM0Mg6y4GO1kxeLLuC0eorkB/LWFCo2XNKKS
 I2Yg==
X-Forwarded-Encrypted: i=1;
 AFNElJ+x1+AqncemiQmbtI4bHUnbOD5NjHuZk7kDhUgNVOZs+yr1Na+wf+sSgnKLC5tHzQfWddPLWz7CQ1jUz/Q=@lists.lustre.org
X-Gm-Message-State: AOJu0Yy8joQJ1BhzBeG9h1UpmnG5IgNJillw+3Y7cjCgU9V18wtdC0vG
 JqcygTpA0x3HgBIO43QARYZQQ2ttm+tTlM+PEvlCrqs/xJmGAwJVsShAMG6C2IOFkmEPn4ApCoR
 tvv1KY7/NyP7lHOldb8A1WjOIH7jtD3Q=
X-Gm-Gg: AeBDievXZjfCy7xKvvRLLNw2Pv+imlJZ/klGQST0r8gsL/G04SodyougpO+QHJmesxD
 X9hUuKLyOVIaoQtCXmdaqvfRxuONTp4Nm7Lw3runvUdMnJnNbaIaEh85kCcFkTiPdMHSq6WGgdF
 6hSXzqcUBQqpAHl45ScmyKsXzhKQmOXXPxONSsvw3GxhT4CbAzTxRbcsYvTVn/E92Eztrxy31sM
 ftB/TIywNR5RkV1q86wlPIJ7/P7Hq5NqDFPn855kfZTSzlHub63yzLbcOb7KhXL+alNPy+dd7KS
 he04LfI9TpKKndwSwikR36M5mAo=
X-Received: by 2002:a05:6830:4493:b0:7db:d1f3:242e with SMTP id
 46e09a7af769-7dc27e18654mr12802539a34.23.1776247516359; Wed, 15 Apr 2026
 03:05:16 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 15 Apr 2026 02:05:06 -0800
X-Gm-Features: AQROBzCIzI3t4HoN7DqRJqGhfcYLuCJfYXBMyULX9MfrK7GMcfb0TbKcnIsdNXA
Message-ID: <CAFhHJgnOoQs94G7_8UsjkpBDp=dgY-BrdhWmy79cmAoF3F5XSg@mail.gmail.com>
To: adilger@thelustrecollective.com, lustre-devel@lists.lustre.org
Subject: [lustre-devel] [REQUEST] Reserve OBD_CONNECT2_PERFSTATS flag value
 0x100000000000ULL
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
From: GEORGE ZHAO via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: GEORGE ZHAO <georgezhaojobs@gmail.com>
Content-Type: multipart/mixed; boundary="===============1910517859189710905=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============1910517859189710905==
Content-Type: multipart/alternative; boundary="0000000000003eee06064f7cda4a"

--0000000000003eee06064f7cda4a
Content-Type: text/plain; charset="UTF-8"

Hi Andreas, hi lustre-devel,

I would like to reserve the following OBD_CONNECT2 flag value for the
LU-7880 feature:

#define OBD_CONNECT2_PERFSTATS  0x100000000000ULL  /* perf stats in statfs
*/

Jira: https://jira.whamcloud.com/browse/LU-7880
Gerrit: https://review.whamcloud.com/c/fs/lustre-release/+/59547

Once confirmed, I will submit a small standalone patch to reserve this flag

Thanks,
George Z. Zhao

--0000000000003eee06064f7cda4a
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi Andreas, hi lustre-devel,<br><br>I would like to reserv=
e the following OBD_CONNECT2 flag value for the LU-7880 feature:<div><br></=
div><div>#define OBD_CONNECT2_PERFSTATS =C2=A00x100000000000ULL =C2=A0/* pe=
rf stats in statfs */</div><div><br></div><div>Jira: <a href=3D"https://jir=
a.whamcloud.com/browse/LU-7880">https://jira.whamcloud.com/browse/LU-7880</=
a><br>Gerrit: <a href=3D"https://review.whamcloud.com/c/fs/lustre-release/+=
/59547">https://review.whamcloud.com/c/fs/lustre-release/+/59547</a></div><=
div><br></div><div>Once confirmed, I will submit a small standalone patch t=
o reserve this flag</div><div><br></div><div>Thanks,<br>George Z. Zhao</div=
><div><br></div></div>

--0000000000003eee06064f7cda4a--

--===============1910517859189710905==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============1910517859189710905==--

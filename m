Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 63795C433EF
	for <lustre-devel@archiver.kernel.org>; Wed, 24 Nov 2021 09:45:46 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id DCDA921CA0B;
	Wed, 24 Nov 2021 01:45:45 -0800 (PST)
Received: from mail-yb1-f181.google.com (mail-yb1-f181.google.com
 [209.85.219.181])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8D15D201106
 for <lustre-devel@lists.lustre.org>; Wed, 24 Nov 2021 01:45:43 -0800 (PST)
Received: by mail-yb1-f181.google.com with SMTP id 131so5567865ybc.7
 for <lustre-devel@lists.lustre.org>; Wed, 24 Nov 2021 01:45:43 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linaro.org; s=google;
 h=mime-version:from:date:message-id:subject:to:cc;
 bh=+1RiNJCfc+5zWsnfDV1JlLwlO/ByPOwgGhFIvK8gQVA=;
 b=YXypjovHmRE+8OCGhEp5Ka+M8F3fND9Mtp/NocyDiqvCb27fkrfjJ14vdyErqfjEU1
 b8ME/bbpFG2QmiDiVNDrfKdg36RuPZ2h/6IFN/9axWM5ORDGh3eyowX4jfuLSSJwi8ll
 dHPjB7s6yMuBH6Dd9YzWivKB5zuDGd8Ss6M9fWNqXCTjgVIBOfaWCMrR0DHq4nmIIAcq
 rIIwETEJ2SHQQwjPo+PEQ8/sGytEvzf/aeX4etWsXOLEiYq4hcVGuPcPY3DesXYO/G8D
 bdBI9daUHlVBQuu3skx2G0JXlKFnjwtKNNwyCKQwv9jKRzYixKVDf1e+7XGHUYvD17be
 PzLA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20210112;
 h=x-gm-message-state:mime-version:from:date:message-id:subject:to:cc;
 bh=+1RiNJCfc+5zWsnfDV1JlLwlO/ByPOwgGhFIvK8gQVA=;
 b=t+5AM7ovEoqt0M6QTucb2uEo1tcZLjEVj+b/+yN+TeKjr2uvInc+cxuTUSPmBi+yx+
 nWlk4i6gPRZ/vKkTiwfOIc6vGrq4NUA2RT5CN7wfr0/eWT6CWXHx7xzsHHosQj0uI+8w
 NY/DKp5Rp1iHPrSN6iChmCiLhXRbFq6zaiU+LDr/5Fxok+rnrkFh7fm+UHkscYFvdlss
 oIrju6rpoVX8WTp/Y/IKwd1B7IMCHE3D4ZkfybKOthi6IPt+AEQcaU/q3tnDLIl/uvKx
 pNduUoWZyPGV7ffQpaLuaS+twBcaJeDSu4oSOY7CVF4prOE/JB6RYMMUH+MWmRDivZw8
 PvQg==
X-Gm-Message-State: AOAM532Fb0xbQlYKjLIt4LwITfdgaWuOH0SqAYY+AzMyo28J3KuZUGFa
 lw1Q80VIQpmmc/SK9qQZprgHfAPGvdhox+psccdIB/yF/34Vk1fnppo=
X-Google-Smtp-Source: ABdhPJxnfuZRBtolvBOqgmkEeWZFSz+eyJ6Nzvx5qckpS6Psk5F8stZg3bR2PtFirOrWvThPGS57blESPwk6QTZQxvI=
X-Received: by 2002:a25:330b:: with SMTP id z11mr14707416ybz.511.1637747142606; 
 Wed, 24 Nov 2021 01:45:42 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 24 Nov 2021 17:45:08 +0800
Message-ID: <CAKoKPbyin6b2CPT18YzEeY6JBRnWgmepS7B3ToSxsW_7nDmRqQ@mail.gmail.com>
To: lustre-devel@lists.lustre.org
Subject: [lustre-devel] Arm client is not in CI?
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
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
From: Xinliang Liu via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Xinliang Liu <xinliang.liu@linaro.org>
Cc: cloud-dev-request@op-lists.linaro.org
Content-Type: multipart/mixed; boundary="===============8809820221417154481=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============8809820221417154481==
Content-Type: multipart/alternative; boundary="000000000000aada2805d185b83c"

--000000000000aada2805d185b83c
Content-Type: text/plain; charset="UTF-8"

Hi,
Recently, I find that Test-Parameters "clientarch=aarch64 " is not
supported in CI yet.
Any reason why arm client is removed? I have some patches which address arm
client or server failed test cases to be landed.

Here is the CI comment that says "clientarch=aarch64" is not supported:
Which is copied from https://review.whamcloud.com/#/c/40758/
''

Patch Set 15:

Build 84492 (patch #15) will not be tested because: Unsupported build
configurations were specified in the Test-Parameters:

Test-Parameters line #1:
- client: el8.3 - aarch64 - inkernel | lustre-reviews #84492
Test-Parameters line #2:
- client: el8.3 - aarch64 - inkernel | lustre-reviews #84492
Test-Parameters line #3:
- client: el8.3 - aarch64 - inkernel | lustre-reviews #84492

Supported build configurations for lustre-reviews #84492:
Clients
- el7.8 - x86_64 - inkernel
- el7.9 - x86_64 - inkernel
- el8.3 - x86_64 - inkernel
- el8.4 - x86_64 - inkernel
- sles12sp5 - x86_64 - inkernel
- sles15sp2 - x86_64 - inkernel
- sles15sp3 - x86_64 - inkernel
- ubuntu1804 - x86_64 - inkernel
- ubuntu2004 - x86_64 - inkernel
Servers
- el7.8 - x86_64 - inkernel
- el7.9 - x86_64 - inkernel
- el8.3 - x86_64 - inkernel
- el8.4 - x86_64 - inkernel
"

Thanks,
Xinliang

--000000000000aada2805d185b83c
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi,=C2=A0<div>Recently, I find that Test-Parameters &quot;=
clientarch=3Daarch64 &quot; is not supported in CI yet.=C2=A0</div><div>Any=
 reason why arm client is removed? I have some patches which address arm cl=
ient or server failed test cases to be landed.</div><div><br></div><div>Her=
e is the CI comment that says &quot;clientarch=3Daarch64&quot; is not suppo=
rted:</div><div>Which is copied from=C2=A0<a href=3D"https://review.whamclo=
ud.com/#/c/40758/" target=3D"_blank">https://review.whamcloud.com/#/c/40758=
/</a><br></div><div>&#39;&#39;</div><div><p style=3D"white-space:pre-wrap;c=
olor:rgb(53,53,53);font-family:sans-serif">Patch Set 15:</p><p style=3D"whi=
te-space:pre-wrap;color:rgb(53,53,53);font-family:sans-serif">Build 84492 (=
patch #15) will not be tested because: Unsupported build configurations wer=
e specified in the Test-Parameters:</p><p style=3D"white-space:pre-wrap;col=
or:rgb(53,53,53);font-family:sans-serif"><span style=3D"font-family:&quot;L=
ucida Console&quot;,&quot;Lucida Sans Typewriter&quot;,Monaco,monospace">Te=
st-Parameters line #1:</span><br><span style=3D"font-family:&quot;Lucida Co=
nsole&quot;,&quot;Lucida Sans Typewriter&quot;,Monaco,monospace">  - client=
: el8.3 - aarch64 - inkernel | lustre-reviews #84492</span><br><span style=
=3D"font-family:&quot;Lucida Console&quot;,&quot;Lucida Sans Typewriter&quo=
t;,Monaco,monospace">Test-Parameters line #2:</span><br><span style=3D"font=
-family:&quot;Lucida Console&quot;,&quot;Lucida Sans Typewriter&quot;,Monac=
o,monospace">  - client: el8.3 - aarch64 - inkernel | lustre-reviews #84492=
</span><br><span style=3D"font-family:&quot;Lucida Console&quot;,&quot;Luci=
da Sans Typewriter&quot;,Monaco,monospace">Test-Parameters line #3:</span><=
br><span style=3D"font-family:&quot;Lucida Console&quot;,&quot;Lucida Sans =
Typewriter&quot;,Monaco,monospace">  - client: el8.3 - aarch64 - inkernel |=
 lustre-reviews #84492</span><br></p><p style=3D"white-space:pre-wrap;color=
:rgb(53,53,53);font-family:sans-serif"><span style=3D"font-family:&quot;Luc=
ida Console&quot;,&quot;Lucida Sans Typewriter&quot;,Monaco,monospace">Supp=
orted build configurations for lustre-reviews #84492:</span><br><span style=
=3D"font-family:&quot;Lucida Console&quot;,&quot;Lucida Sans Typewriter&quo=
t;,Monaco,monospace">Clients</span><br><span style=3D"font-family:&quot;Luc=
ida Console&quot;,&quot;Lucida Sans Typewriter&quot;,Monaco,monospace">  - =
el7.8      - x86_64 - inkernel</span><br><span style=3D"font-family:&quot;L=
ucida Console&quot;,&quot;Lucida Sans Typewriter&quot;,Monaco,monospace">  =
- el7.9      - x86_64 - inkernel</span><br><span style=3D"font-family:&quot=
;Lucida Console&quot;,&quot;Lucida Sans Typewriter&quot;,Monaco,monospace">=
  - el8.3      - x86_64 - inkernel</span><br><span style=3D"font-family:&qu=
ot;Lucida Console&quot;,&quot;Lucida Sans Typewriter&quot;,Monaco,monospace=
">  - el8.4      - x86_64 - inkernel</span><br><span style=3D"font-family:&=
quot;Lucida Console&quot;,&quot;Lucida Sans Typewriter&quot;,Monaco,monospa=
ce">  - sles12sp5  - x86_64 - inkernel</span><br><span style=3D"font-family=
:&quot;Lucida Console&quot;,&quot;Lucida Sans Typewriter&quot;,Monaco,monos=
pace">  - sles15sp2  - x86_64 - inkernel</span><br><span style=3D"font-fami=
ly:&quot;Lucida Console&quot;,&quot;Lucida Sans Typewriter&quot;,Monaco,mon=
ospace">  - sles15sp3  - x86_64 - inkernel</span><br><span style=3D"font-fa=
mily:&quot;Lucida Console&quot;,&quot;Lucida Sans Typewriter&quot;,Monaco,m=
onospace">  - ubuntu1804 - x86_64 - inkernel</span><br><span style=3D"font-=
family:&quot;Lucida Console&quot;,&quot;Lucida Sans Typewriter&quot;,Monaco=
,monospace">  - ubuntu2004 - x86_64 - inkernel</span><br><span style=3D"fon=
t-family:&quot;Lucida Console&quot;,&quot;Lucida Sans Typewriter&quot;,Mona=
co,monospace">Servers</span><br><span style=3D"font-family:&quot;Lucida Con=
sole&quot;,&quot;Lucida Sans Typewriter&quot;,Monaco,monospace">  - el7.8 -=
 x86_64 - inkernel</span><br><span style=3D"font-family:&quot;Lucida Consol=
e&quot;,&quot;Lucida Sans Typewriter&quot;,Monaco,monospace">  - el7.9 - x8=
6_64 - inkernel</span><br><span style=3D"font-family:&quot;Lucida Console&q=
uot;,&quot;Lucida Sans Typewriter&quot;,Monaco,monospace">  - el8.3 - x86_6=
4 - inkernel</span><br><span style=3D"font-family:&quot;Lucida Console&quot=
;,&quot;Lucida Sans Typewriter&quot;,Monaco,monospace">  - el8.4 - x86_64 -=
 inkernel</span></p></div><div>&quot;</div><div><br></div><div>Thanks,</div=
><div>Xinliang</div></div>

--000000000000aada2805d185b83c--

--===============8809820221417154481==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============8809820221417154481==--

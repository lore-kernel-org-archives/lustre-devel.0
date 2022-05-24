Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id C033FC433EF
	for <lustre-devel@archiver.kernel.org>; Tue, 24 May 2022 19:34:53 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B40C921F728;
	Tue, 24 May 2022 12:34:51 -0700 (PDT)
Received: from mxchg03.rrz.uni-hamburg.de (mxchg03.rrz.uni-hamburg.de
 [134.100.38.113])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8F60021F700;
 Tue, 24 May 2022 12:34:40 -0700 (PDT)
Authentication-Results: mxchg03.rrz.uni-hamburg.de (amavisd-new);
 dkim=pass (2048-bit key) reason="pass (just generated, assumed good)"
 header.d=uni-hamburg.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=uni-hamburg.de;
 h=subject:subject:from:from:to:user-agent:mime-version:date
 :date:message-id:content-type:content-type; s=rrzs002; t=
 1653420878; x=1654284879; bh=scwEbiGaR3n5RR/30s9HBMmOmPhblCcEZCS
 5qazCAZE=; b=pIMzJRSfZEMhez2aPAyIFcuBr6iLx5Uy2NFEZbqSmTacKz4yJgb
 xeofDhaHEILwZ5f0GBZzsatLXqHo5ZjELb9y7FrkFsEX7yjDF46ImvPTwnlkPffF
 DwbBTOfmj02fOBF/BxzjFgnJvDHxWZH31I1fzypcZxNBmzYnhUsNtcSVjiz6biG9
 IVOLMji1Wej99yjz4ankQzPsquuzT79k4fWRdEw6Gf6m3Am0Os7S1VoMT+bcwsvY
 rL/qFdXw0gXgEX+3pSPrSOYQ9J0KPrNDyMdnGN+Tj0k1XTSwnIFKIzmzlr0TqYWM
 xoYLrogDEjgmWRDUifiFQiAfqNWbPNK65/w==
X-Virus-Scanned: by University of Hamburg ( RRZ / mgw05.rrz.uni-hamburg.de )
Received: from exchange.uni-hamburg.de (UN-EX-MR03.uni-hamburg.de
 [134.100.84.70]) by mxchg03.rrz.uni-hamburg.de (Postfix) with ESMTPS;
 Tue, 24 May 2022 21:34:38 +0200 (CEST)
Received: from [192.168.178.28] (46.59.212.222) by UN-EX-MR03.uni-hamburg.de
 (134.100.84.70) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P256) id 15.1.2507.9; Tue, 24
 May 2022 21:34:37 +0200
Message-ID: <d7a983ae-4aa8-1e25-4755-e4417e7a93c1@informatik.uni-hamburg.de>
Date: Tue, 24 May 2022 21:34:34 +0200
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:91.0) Gecko/20100101
 Thunderbird/91.9.1
To: <lustre-discuss@lists.lustre.org>, Lustre Development List
 <lustre-devel@lists.lustre.org>
X-Antivirus: Avast (VPS 220524-4, 24.5.2022), Outbound message
X-Antivirus-Status: Clean
X-Originating-IP: [46.59.212.222]
X-ClientProxiedBy: UN-EX-MR02.uni-hamburg.de (134.100.84.69) To
 UN-EX-MR03.uni-hamburg.de (134.100.84.70)
Subject: [lustre-devel] I/O in HPC applications and systems SURVEY
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
From: Anna Fuchs via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Anna Fuchs <anna.fuchs@informatik.uni-hamburg.de>
Content-Type: multipart/mixed; boundary="===============2557996004510042123=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============2557996004510042123==
Content-Type: multipart/alternative;
	boundary="------------ZNLduPgXpuIDu9CFM0F4TJQM"

--------------ZNLduPgXpuIDu9CFM0F4TJQM
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit

Dear all,

I have prepared a survey 'I/O in HPC applications and systems' for my 
studies about compression in Lustre.
I would be excited if you would fill in the survey and forward the link 
to any user or admin of an HPC system.
https://www.limesurvey.uni-hamburg.de/index.php/237926?lang=en

The most questions are of type multiple choice and it will take you 
about 5-10 minutes.
I would share the results later, if desired.

Thank you for the support!

Best regards
Anna

-- 
Anna Fuchs
Universität Hamburg
https://wr.informatik.uni-hamburg.de

anna.fuchs@informatik.uni-hamburg.de
https://wr.informatik.uni-hamburg.de/people/anna_fuchs

--------------ZNLduPgXpuIDu9CFM0F4TJQM
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: 8bit

<html>
  <head>

    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
  </head>
  <body>
    <div>
      <div id="5xi9ekm8kt8378zgmpex8ns5xy_message" class="post__body ">
        <div class="post-message post-message--collapsed">
          <div style="max-height: 600px;"
            class="post-message__text-container">
            <div aria-readonly="true" tabindex="0"
              id="postMessageText_5xi9ekm8kt8378zgmpex8ns5xy"
              class="post-message__text" dir="auto">Dear all,<br>
              <br>
              I have prepared a survey 'I/O in HPC applications and
              systems' for my studies about compression in Lustre.<br>
              I would be excited if you would fill in the survey and
              forward the link to any user or admin of an HPC system.<br>
              <a
                href="https://www.limesurvey.uni-hamburg.de/index.php/237926?lang=en"
                target="_blank" class="moz-txt-link-freetext">https://www.limesurvey.uni-hamburg.de/index.php/237926?lang=en</a><br>
              <br>
              The most questions are of type multiple choice and it will
              take you about 5-10 minutes.<br>
              I would share the results later, if desired.<br>
              <br>
              Thank you for the support!<br>
              <br>
              Best regards<br>
              Anna<br>
            </div>
          </div>
        </div>
      </div>
    </div>
    <pre class="moz-signature" cols="72">-- 
Anna Fuchs
Universität Hamburg
<a class="moz-txt-link-freetext" href="https://wr.informatik.uni-hamburg.de">https://wr.informatik.uni-hamburg.de</a>

<a class="moz-txt-link-abbreviated" href="mailto:anna.fuchs@informatik.uni-hamburg.de">anna.fuchs@informatik.uni-hamburg.de</a>
<a class="moz-txt-link-freetext" href="https://wr.informatik.uni-hamburg.de/people/anna_fuchs">https://wr.informatik.uni-hamburg.de/people/anna_fuchs</a></pre>
  </body>
</html>

--------------ZNLduPgXpuIDu9CFM0F4TJQM--

--===============2557996004510042123==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============2557996004510042123==--

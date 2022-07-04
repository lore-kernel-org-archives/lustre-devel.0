Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 65168C433EF
	for <lustre-devel@archiver.kernel.org>; Mon,  4 Jul 2022 13:00:00 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Lc5W264Z6z1wTP;
	Mon,  4 Jul 2022 05:59:58 -0700 (PDT)
Received: from mxchg04.rrz.uni-hamburg.de (mxchg04.rrz.uni-hamburg.de
 [134.100.38.114])
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id
 4Lc5W03ns3z1wNP; Mon,  4 Jul 2022 05:59:56 -0700 (PDT)
Authentication-Results: mxchg04.rrz.uni-hamburg.de (amavisd-new);
 dkim=pass (2048-bit key) reason="pass (just generated, assumed good)"
 header.d=uni-hamburg.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=uni-hamburg.de;
 h=in-reply-to:references:to:from:from:subject:subject
 :user-agent:mime-version:date:date:message-id:content-type
 :content-type; s=rrzs002; t=1656939594; x=1657803595; bh=zKU9N7E
 WgROlZhgsIEMGy1I9KE59nMLC4KdNgjBfXvA=; b=tAwygnl3p/23pvYCmGKjLpT
 TXjiN9NM2uOjA9zPKzXznYqqp7279A+vOmW9+BwWFnDhbC6d6XrJrRd3yhMEH4vo
 Z10kXtPKwK0scaDlEbsKKmz/ik5lLppzgoy2Qm1KYOtJ43/wpwCTLoGBSUf/wqaF
 yPrYFLkkdsxvYnbRShrqTMc5/vTPn57+gz7ppLnMJE7+Qe5ucLtVPaXIeb/BPo+a
 db8fIgKB0KNrQz607YGpibT4vAWdJWfsu3mh9Lxs0Bdu98LEh7u3vx/A4Xo9ZZP4
 eDhxAKVNbcxfCze80ifUEnOdU84tWPTtypFnojURjKpksbT0M77Dn/SudazDyuA=
 =
X-Virus-Scanned: by University of Hamburg ( RRZ / mgw04.rrz.uni-hamburg.de )
Received: from exchange.uni-hamburg.de (UN-EX-MR03.uni-hamburg.de
 [134.100.84.70]) by mxchg04.rrz.uni-hamburg.de (Postfix) with ESMTPS;
 Mon,  4 Jul 2022 14:59:54 +0200 (CEST)
Received: from [134.100.4.18] (134.100.5.65) by UN-EX-MR03.uni-hamburg.de
 (134.100.84.70) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P256) id 15.1.2507.9; Mon, 4 Jul
 2022 14:59:53 +0200
Message-ID: <8389d71c-9370-63c8-1bae-d59cc5ebf6b4@informatik.uni-hamburg.de>
Date: Mon, 4 Jul 2022 14:59:51 +0200
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:91.0) Gecko/20100101
 Thunderbird/91.11.0
To: <lustre-discuss@lists.lustre.org>, Lustre Development List
 <lustre-devel@lists.lustre.org>
References: <d7a983ae-4aa8-1e25-4755-e4417e7a93c1@informatik.uni-hamburg.de>
In-Reply-To: <d7a983ae-4aa8-1e25-4755-e4417e7a93c1@informatik.uni-hamburg.de>
X-Antivirus: Avast (VPS 220704-0, 4.7.2022), Outbound message
X-Antivirus-Status: Clean
X-Originating-IP: [134.100.5.65]
X-ClientProxiedBy: UN-EX-MR08.uni-hamburg.de (134.100.84.75) To
 UN-EX-MR03.uni-hamburg.de (134.100.84.70)
Subject: Re: [lustre-devel] I/O in HPC applications and systems SURVEY
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
From: Anna Fuchs via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Anna Fuchs <anna.fuchs@informatik.uni-hamburg.de>
Content-Type: multipart/mixed; boundary="===============5069599026002586306=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============5069599026002586306==
Content-Type: multipart/alternative;
	boundary="------------0znTvytHN3QfPOR0cvXU4YIj"

--------------0znTvytHN3QfPOR0cvXU4YIj
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit

Reminder:

Dear all,

this is a short reminder.
In case you've postponed the survey, please, take the opportunity to 
make a contribution.
I've recieved more than a hundred responses and want to thank you all!

Best regards
Anna

Am 24.05.2022 um 21:34 schrieb Anna Fuchs:
> Dear all,
>
> I have prepared a survey 'I/O in HPC applications and systems' for my 
> studies about compression in Lustre.
> I would be excited if you would fill in the survey and forward the 
> link to any user or admin of an HPC system.
> https://www.limesurvey.uni-hamburg.de/index.php/237926?lang=en
>
> The most questions are of type multiple choice and it will take you 
> about 5-10 minutes.
> I would share the results later, if desired.
>
> Thank you for the support!
>
> Best regards
> Anna
> -- 
> Anna Fuchs
> Universität Hamburg
> https://wr.informatik.uni-hamburg.de
>
> anna.fuchs@informatik.uni-hamburg.de
> https://wr.informatik.uni-hamburg.de/people/anna_fuchs

-- 
Anna Fuchs
Universität Hamburg
https://wr.informatik.uni-hamburg.de

anna.fuchs@informatik.uni-hamburg.de
https://wr.informatik.uni-hamburg.de/people/anna_fuchs

--------------0znTvytHN3QfPOR0cvXU4YIj
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: 8bit

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  </head>
  <body>
    Reminder:<br>
    <br>
    Dear all,<br>
    <br>
    this is a short reminder.<br>
    In case you've postponed the survey, please, take the opportunity to
    make a contribution.<br>
    I've recieved more than a hundred responses and want to thank you
    all!<br>
    <br>
    Best regards<br>
    Anna<br>
    <br>
    <div class="moz-cite-prefix">Am 24.05.2022 um 21:34 schrieb Anna
      Fuchs:<br>
    </div>
    <blockquote type="cite"
cite="mid:d7a983ae-4aa8-1e25-4755-e4417e7a93c1@informatik.uni-hamburg.de">
      <meta http-equiv="content-type" content="text/html; charset=UTF-8">
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
                  target="_blank" class="moz-txt-link-freetext"
                  moz-do-not-send="true">https://www.limesurvey.uni-hamburg.de/index.php/237926?lang=en</a><br>
                <br>
                The most questions are of type multiple choice and it
                will take you about 5-10 minutes.<br>
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
<a class="moz-txt-link-freetext" href="https://wr.informatik.uni-hamburg.de" moz-do-not-send="true">https://wr.informatik.uni-hamburg.de</a>

<a class="moz-txt-link-abbreviated moz-txt-link-freetext" href="mailto:anna.fuchs@informatik.uni-hamburg.de" moz-do-not-send="true">anna.fuchs@informatik.uni-hamburg.de</a>
<a class="moz-txt-link-freetext" href="https://wr.informatik.uni-hamburg.de/people/anna_fuchs" moz-do-not-send="true">https://wr.informatik.uni-hamburg.de/people/anna_fuchs</a></pre>
    </blockquote>
    <br>
    <pre class="moz-signature" cols="72">-- 
Anna Fuchs
Universität Hamburg
<a class="moz-txt-link-freetext" href="https://wr.informatik.uni-hamburg.de">https://wr.informatik.uni-hamburg.de</a>

<a class="moz-txt-link-abbreviated" href="mailto:anna.fuchs@informatik.uni-hamburg.de">anna.fuchs@informatik.uni-hamburg.de</a>
<a class="moz-txt-link-freetext" href="https://wr.informatik.uni-hamburg.de/people/anna_fuchs">https://wr.informatik.uni-hamburg.de/people/anna_fuchs</a></pre>
  </body>
</html>

--------------0znTvytHN3QfPOR0cvXU4YIj--

--===============5069599026002586306==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============5069599026002586306==--

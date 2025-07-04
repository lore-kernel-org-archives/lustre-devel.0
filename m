Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id E4C59C83F03
	for <lustre-devel@archiver.kernel.org>; Fri,  4 Jul 2025 20:23:21 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4bYlGN20Rdz23M0;
	Fri, 04 Jul 2025 13:14:20 -0700 (PDT)
Received: from mail-wm1-f53.google.com (mail-wm1-f53.google.com
 [209.85.128.53])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4bYl2K2d97z20js
 for <lustre-devel@lists.lustre.org>; Fri, 04 Jul 2025 13:03:53 -0700 (PDT)
Received: by mail-wm1-f53.google.com with SMTP id
 5b1f17b1804b1-454b9185d93so118925e9.2
 for <lustre-devel@lists.lustre.org>; Fri, 04 Jul 2025 13:03:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1751659387; x=1752264187; darn=lists.lustre.org;
 h=content-transfer-encoding:in-reply-to:cc:content-language
 :references:to:subject:from:mime-version:date:message-id:from:to:cc
 :subject:date:message-id:reply-to;
 bh=pct7Br6Rs8Fbyqw6BNiP3EVj79J28OhuF0H7xmQRAwc=;
 b=IHThN4GTVM6c2iwqWwYPYUpcf3EQVTG1tfHW9bKcLcrUwFp6LfrWCklzYYGWHmuQ8e
 LRGZ8o+ddEGasQfouDKlJDmVJXjVNLZmAa/ipNQOTiTD+/+fhrUV3a2OkzevunbJQUqB
 Xy/HAFpH+TVvhVeuaWrJJodhDlGUywoF+7+KzmIRiD6Lx4clFHtROZcflVW3zEpajH5m
 TzSUiL5LAWfnIwKXsfzt+jp7BRYGF7fZZfrlGt9vU1uxRTfCnB13NO5wP1hBUCLK8ebs
 7J3OXGyGcOhP4pLxflV6/q6oHuEi4G5NYtLcuqNgACfYs9HyGqvY8bFmdwiYv3AQnk9v
 bbsA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1751659387; x=1752264187;
 h=content-transfer-encoding:in-reply-to:cc:content-language
 :references:to:subject:from:mime-version:date:message-id
 :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
 bh=pct7Br6Rs8Fbyqw6BNiP3EVj79J28OhuF0H7xmQRAwc=;
 b=KqfQGzfROFCHcuBYaEGsq7tXSep6YnZQQhExdKvlQ2QpoqT2n6acrymmfxEXLvLtIS
 +k27JsYtT0dsbsJCZsg4WnD1ftSJSgnNriCDpjtW6e8CxvNVsLdvAXUEfGMpK0lmURTZ
 hWXP8KhNcIIRKCqJ4LlWoaNHz6nbsEejhxcxy5eYigE6Af5G35sEvLbEjbKz+NoH0chg
 N/fIq0L1tbsY499A0rUu4FjInWsjrn/iSZd/s0DXXRhOb0kSoF9ydVrK4IwDvAc7jcv5
 f7xIGumYBdA8asVzRrdKCUY0Nw38sDuORH/GLv/TIARkVWxYKFG9IMSCW/gktOn2stgW
 Y/hA==
X-Gm-Message-State: AOJu0YyJ5j8pYhfokoMo0MuwUKo3Z1k+B5yb7St/7W93Dn1SbON+ZpsH
 iWNW/T626XlAS0DYxmCNdvpbGVe8q3bOi08vKU77HS8siHieCqHUl7wP2xKk5j4=
X-Gm-Gg: ASbGncucC45xppv8LVLHdDvC2D3/0K121OVfFaFtUXNOtzHqm9Wds3eaQ+hWGeDE98d
 u068CspUzmKTHCcJVHG9UPursnjeAzK29BRBxvmo3SB7QscIXszq5cL0BmMMkuH7LVTPsqxcA5w
 nhWwxn7LrtNgT7Vyg8A7hJKjF6tCr44BUOHVwUkVACJwIsFzbInA1FxFB70yZuzqIt4Xi0de3sE
 dEw37pTvqGdl5/kbJM7g6Z3ZH0p9THZ3W4k7XEmWuQk8vpDAl9nC2BvSbd8ApgEIr5t6wmgTYHk
 kkdIU+IuNIzUgqYoqgLqiSKqPe+7BOJrSI9HEOAtN2UBV3fGAP1pQnWE4NpIJqES/TqV48sKbOr
 lmXFwbos0gO81c42HRcW7+yJCYQ==
X-Google-Smtp-Source: AGHT+IFXntkePWufZvhbICLsWYrTEiPox7KkQ85NsTYKtdsaiFPAQzo743s/Y3UPYOrpXzWXC1gYIg==
X-Received: by 2002:a05:600c:1c90:b0:43b:ca39:a9b8 with SMTP id
 5b1f17b1804b1-454b35d9e68mr13631175e9.2.1751659386341; 
 Fri, 04 Jul 2025 13:03:06 -0700 (PDT)
Received: from localhost (133.red-80-39-56.staticip.rima-tde.net.
 [80.39.56.133]) by smtp.gmail.com with ESMTPSA id
 5b1f17b1804b1-453a85ab932sm75227535e9.0.2025.07.04.13.03.05
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Fri, 04 Jul 2025 13:03:05 -0700 (PDT)
Message-ID: <f9b6273c-6f1f-41fd-936e-305161c09842@gmail.com>
Date: Fri, 4 Jul 2025 22:03:04 +0200
MIME-Version: 1.0
To: "Day, Timothy" <timday@amazon.com>
References: <20250620195720.59870-1-xose.vazquez@gmail.com>
 <2698F449-3C9E-4934-980D-619A013EE51D@amazon.com>
 <3e7322b2-fa65-4850-a662-0d82c597b23f@gmail.com>
 <95604993-0061-4C2F-B362-B2394BE0656B@amazon.com>
Content-Language: en-US, en-GB, es-ES
Cc: LUSTRE DEVEL ML <lustre-devel@lists.lustre.org>
In-Reply-To: <95604993-0061-4C2F-B362-B2394BE0656B@amazon.com>
Subject: Re: [lustre-devel] [PATCH 1/2] lustre: refresh FSF licences
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
From: Xose Vazquez Perez via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Xose Vazquez Perez <xose.vazquez@gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

On 6/24/25 7:47 PM, Day, Timothy wrote:

[CC lustre-devel ml]

>>> The license text is copied verbatim from the Linux kernel [1]. I think
>>> we should stay aligned with that. Also, Lustre uses Gerrit to submit
>>> patches. I've linked the wiki with instructions on the current process.
>>>
>>> Tim Day
>>>
>>> [1] https://github.com/torvalds/linux/tree/master/LICENSES/preferred <https://github.com/torvalds/linux/tree/master/LICENSES/preferred>
>>> [2] https://wiki.lustre.org/Submitting_Changes <https://wiki.lustre.org/Submitting_Changes>

>> [out of the list because size limit]
>>
>> There was a related 2/2 patch, but it was blocked by the mailing list filter (attached).
>>
>> It is a licence boilerplate cleanup, you can do with it whatever you want.

> Thanks for working on this. I'm really happy to see the rest of
> this license boilerplate removed.

My 2/2 patch only deleted the GPL ones.

But there are still some licences left in the code at:
lustre/ptlrpc/gss/gss_asn1.h
lustre/ptlrpc/gss/gss_err.h
lustre/ptlrpc/gss/gss_generic_token.c
lustre/ptlrpc/gss/gss_krb5.h
lustre/scripts/statechange-lustre.sh
lustre/tests/fsx.c
lustre/utils/gss/cacheio.c
lustre/utils/gss/cacheio.h
lustre/utils/gss/context.c
lustre/utils/gss/context.h
lustre/utils/gss/context_lucid.c
lustre/utils/gss/context_spkm3.c
lustre/utils/gss/err_util.c
lustre/utils/gss/err_util.h
lustre/utils/gss/gss_oids.c
lustre/utils/gss/gss_oids.h
lustre/utils/gss/gss_util.c
lustre/utils/gss/gss_util.h
lustre/utils/gss/lgss_krb5_utils.c
lustre/utils/gss/lgss_utils.c
lustre/utils/gss/lgss_utils.h
lustre/utils/gss/svcgssd.c
lustre/utils/gss/svcgssd.h
lustre/utils/gss/svcgssd_main_loop.c
lustre/utils/gss/svcgssd_mech2file.c
lustre/utils/gss/svcgssd_proc.c
lustre/utils/gss/write_bytes.h


And more junk could be deleted, such as:

- trivial messages (at least for the kernel code):
git grep -i "Use is subject to license terms"
git grep -i "This file is part of"

- old urls:
git grep -i "ftp:.*"
git grep -i "http.*" | grep -viE "lustre\.org|gnu\.org|whamcloud\.com|kernel\.org|github\.com|spdx\.org"

- and, deprecated code ???
git grep -i oracle_ofed_ext
git grep IB_DEVICE_MEM_MGT_EXTENSIONS

> I can submit the second patch to our
> Gerrit instance on your behalf. Lustre really ought to establish
> a process for accepting patches from our mailing list. But right
> now, Gerrit is all we have.

If you(lustre team) are aiming to include Lustre in the official
Linux repository, you will have to change your current workflow.
It is incompatible with upstream development.

> For the first patch, I think it'd make sense to submit your change> to upstream kernel first, then Lustre can get the changes afterwards.

I did try it, but they are perfectly happy with their unstructured,
and outdated, licences files:
https://marc.info/?t=175046892800001
https://marc.info/?t=175046893000002


Thanks.
_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

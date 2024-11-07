Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 32993D5D66F
	for <lustre-devel@archiver.kernel.org>; Thu,  7 Nov 2024 17:19:06 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4XkphT0SsWz1wkm;
	Thu, 07 Nov 2024 09:19:05 -0800 (PST)
Received: from mail.someonex.net (mail.someonex.net [5.2.76.123])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4XkphR3GW7z1wQP
 for <lustre-devel@lists.lustre.org>; Thu, 07 Nov 2024 09:19:03 -0800 (PST)
Message-ID: <7da775ec-4884-4059-ad00-d591166a32ce@someonex.net>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=someonex.net;
 s=mail; t=1730999939;
 bh=t3bwQr9HgkJPTSFN/EFxG4vGD6XDt62SPlQLvXK0QHQ=;
 h=Date:To:From:Subject;
 b=BdUghX3nvI7c2NGUgNQT/QGSKBqoYczwWH1wFqSmI5bAdLwbVW6lcqSnOwaj84dRZ
 K2Sy5RI9D8xspAqhHL9LcDZz021Q89c+BKxlfG2kG4MqI/K3FHIU+hP49YYc53iLlu
 ZCpPjn5rmYvndeRiuVhCdKqHCidBwyfCwwJTOQ+0=
Date: Thu, 7 Nov 2024 17:18:58 +0000
MIME-Version: 1.0
Content-Language: en-US
To: lustre-devel@lists.lustre.org
From: Else Someone <else@someonex.net>
Organization: someonex.net
Subject: [lustre-devel] Ldiskfs: kernel version triplet policy
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
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

Hi! I've been looking into building Lustre using Nix and 
[Nixpkgs](https://github.com/NixOS/nixpkgs), and I plan to upstream 
Lustre support into the distribution in a foreseeable future. One of the 
struggles so far has been with patch-sets for the ldiskfs module: in my 
case[^1][^2] the configuration script selects the `ldiskfs-6.6-ml.series 
` for the kernel version `6.6.57`, which would not apply cleanly. The 
way I went about this is I reapplied the failing patches manually, 
copying them into the same `patches/linux-6.6` directory, and editing 
`series/ldiskfs-6.6-ml.series` in-place. The same patchset I've prepared 
for `6.6.57` does not apply, for example, to `6.6.53`.


Seeing as patch series are named after major versions (minor semvers), I 
wonder if the convention is to keep patches in sync with the latest 
patch version in the release? If not, what is the rule? Would consider 
accepting these updated patches if I were to submit them, or do you 
prefer to maintain these by yourselves? Thanks!


[^1]: Kernel release 
https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.6.57.tar.xz

[^2]: Nixpkgs revision 
https://releases.nixos.org/nixpkgs/nixpkgs-24.11pre695130.ca30f584e180/nixexprs.tar.xz 


_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

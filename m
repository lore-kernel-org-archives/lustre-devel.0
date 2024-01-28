Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id EF00FC47258
	for <lustre-devel@archiver.kernel.org>; Sun, 28 Jan 2024 05:13:41 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4TN02W1FSJz1y3n;
	Sat, 27 Jan 2024 21:13:39 -0800 (PST)
Received: from outbound-ip168b.ess.barracuda.com
 (outbound-ip168b.ess.barracuda.com [209.222.82.102])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4TN02N05hNz1wVt
 for <lustre-devel@lists.lustre.org>; Sat, 27 Jan 2024 21:13:31 -0800 (PST)
Received: from NAM12-MW2-obe.outbound.protection.outlook.com
 (mail-mw2nam12lp2040.outbound.protection.outlook.com [104.47.66.40]) by
 mx-outbound42-55.us-east-2c.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Sun, 28 Jan 2024 05:13:29 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=mAg+fUU3UN5Fvgqp+OvuXvRjf0lOb4jx9kWyvn6l6rHXTAxzlUUPJ+d9BJNZEcltZKbUQy+Au/vMCnHgAShauNtLymHelAn7KsF6SAJW6Tm1kMUZVWBuGie8foGPWpQ/sizsh5LzGkMk4KrROnP00k8wHrcD2yuuoD8/GJH/AF3uNgunRTgEGGlxBKuj2Y1dwqz6vchsoLxj21jLayTvrDkZdmZLTa54cy/+21wpjG/lZEYTK0CDc0KjTCHpwTmca7phrKJ/sxQ7jc2/XFT2NX0cKaczuQ6w4+Hg1pK6F3aQNmUpswd9ZGB3GRJPXVopy7H+JCmhqaleVERbMTjZEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=0gVPlPAJYCdmp9Ng6draauA/xUprOWzrxAeEO36HKZA=;
 b=iznw1lkDXJ61zhT+peaeMB8yaxQjs4FTid+AGc4lXsSDw8DssF/tjNEDVkO4aGSvuaQwLmO2VMpV+wZY5rBPV7GsLo0Gz9R7JBbwpu92ImEFvXQwrw3kQqp4U12i0+vPP3sSSoYbm8MxA4JW4qln5oyLOQte+EzhOPSuL03dFQQiUBwkeP/sVwzhswch7HYZJ6hKJzO7RQN20q36aI+iRfr8ZZwSp/RL6iOCUXeKBgggg5XfUI+70vhkTpf1hB3ZoyGb5oVAKKV6Q7iMyO1Q7ZDPCPrTp30sNW5AEd1zlBX3s2mj3s3yUPfKwTR2lm8dO2+ORhUnfTTmeWhxjH+ldg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=0gVPlPAJYCdmp9Ng6draauA/xUprOWzrxAeEO36HKZA=;
 b=jBkYZICXFKpIr2k12/WoT0lyn20kj9Do965AUcqsI2YQDEjCyaArZYoVbotyINHkLLa5j8rJeJhGbydxfeelxRDtUWUCrBtcIU2zW47U7yE21+xm9DHvpi7pyk5HUvRmN8TvZlZ5+nmuYFkcRVzH2joPyzNZ1SUSzvNMx5k6dS0=
Received: from MW4PR19MB5630.namprd19.prod.outlook.com (2603:10b6:303:189::12)
 by SA0PR19MB6907.namprd19.prod.outlook.com (2603:10b6:806:2d5::12)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.7228.31; Sun, 28 Jan
 2024 05:13:26 +0000
Received: from MW4PR19MB5630.namprd19.prod.outlook.com
 ([fe80::22d5:7dc1:2df8:5fdb]) by MW4PR19MB5630.namprd19.prod.outlook.com
 ([fe80::22d5:7dc1:2df8:5fdb%4]) with mapi id 15.20.7202.031; Sun, 28 Jan 2024
 05:13:25 +0000
To: Saisha Kamat <skamat1@charlotte.edu>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: [lustre-devel] Direct Modification of Lustre Metadata on Disk
Thread-Index: AQHaUJIFHTqgsfUPwEGT5tX3XNKoc7DusEsA
Date: Sun, 28 Jan 2024 05:13:25 +0000
Message-ID: <C3A9CCEA-CCB1-41A5-9B40-D99D2E56E535@ddn.com>
References: <CACyzrcQosBre=vRYDN+VeB=o=9bB-mJGT=NrQBhJi_59Eqe7jw@mail.gmail.com>
In-Reply-To: <CACyzrcQosBre=vRYDN+VeB=o=9bB-mJGT=NrQBhJi_59Eqe7jw@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.21)
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: MW4PR19MB5630:EE_|SA0PR19MB6907:EE_
x-ms-office365-filtering-correlation-id: 1bed69bb-0bc3-4644-224b-08dc1fbfdb33
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: 5kVWhuFF9ZA3Xsq29S8pR8+lFdicRHPFtPsJ796nDxqrjcDX3kB7cXSbQ6j0GfeoNP/CIRh88KkvLQ6rXASObovpfVw9v9HvqryRmUGVulx8q06PgbrNcc5WBj7BPDU0cVMaPnPe5O8gkD3Jvxy51iRlQFjMp9c6zJzeukyPzxLvLDWfLXwamhjHI7ju3EEy+SUkmieOjTQMoZEbPNYb64l7wFU9Vjv0fJnxnUxbbsgVMvEgqYIAoXTA1LOKPoFcIf7FRY+z/eK6wT2c7K9HltNJGqTA2Z9BAe9zXBxVB6X1QtfgkCwNivNyzBSKG9LxJxoc5GcwBlARD0yyZ1JYNjUsW4FYQJN4h4w/0HI9esHRR2UaF9vMGNBkcAMlqJXKXvnWGOEi4zYv+y8Zw73zf0QskZjCSUMcSPQegfYjPj88Iiz6KGL33cr+Gc/bMuN1P7xFHFd6JliQ6PmTmpJncxzxMVHLpziwuLthgEvB1Lfhmxn/x4DVL15TY9+ycGV6euTFoZMYFtzWlFw86Y/DLedKqkThvB8IHSv+E0ihlfgJYSv+qCgPmC7a6UvuPwmCI2n71mCf+Og6uvCvZA+VLThfpj3Bze7PrxMQfWGl61Ih6W0YSok+vjMfcrXGx7P4wMIsDm1JMDngsOWKkalPIg==
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MW4PR19MB5630.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230031)(39840400004)(376002)(396003)(366004)(346002)(136003)(230922051799003)(451199024)(1800799012)(186009)(64100799003)(26005)(83380400001)(53546011)(6506007)(6512007)(9686003)(38100700002)(122000001)(5660300002)(4326008)(8676002)(8936002)(41300700001)(2906002)(71200400001)(6486002)(478600001)(316002)(6916009)(64756008)(66446008)(66476007)(66556008)(66946007)(76116006)(33656002)(36756003)(86362001)(38070700009)(13693001);
 DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?us-ascii?Q?b9qNod81+gEMvu87uP4QOHwfD4rlfUQga0IxxmQ42tF9Hmjjb9nj2hYTBqLa?=
 =?us-ascii?Q?Zun2G6zuK2djf9bqZP+TZayuiWSF/08vOaOT0xCfWNKSBcVgvAtuVKdTKkXd?=
 =?us-ascii?Q?pAVuDRhM4jOnYcy9drfTI/9P05zAhMhP5CIJWDDuCdpeQLdNDuXtW9RrFo4q?=
 =?us-ascii?Q?Zim2G1NOvtUQF6RCO2Ipjs1uIJ75MGf+3/qXiM1Dwif0cE/x/vc9qqekxJKy?=
 =?us-ascii?Q?5013rwumka/4rxw/MwZQy4XQpBHQGHNlsICt12dRN9LXcyTuWj4H4GbtfW17?=
 =?us-ascii?Q?rYqwQOLw6JGFE1kxHr+12ivT3ZylbqXKh6TErzHMfq3AO48PsJB560VFLHMm?=
 =?us-ascii?Q?YrCWRLPUi5lRzB3bg2JNWRdKgZ+KeGKFkvI3WACW9wTX+jcnYIXPHMUCsPu9?=
 =?us-ascii?Q?8/+i0CJkbUayiCmoLHhIfNRFsGhwp+Ml82HSOvUZfJ6+SIfp4UB9tvchJ96U?=
 =?us-ascii?Q?tpdPXv+ftS3dtPkERQWlB6+vK+tIwMnbNkC6yj8Dm8Tjbg8uAdd/X2CT19IS?=
 =?us-ascii?Q?nw991yGenssi6eDg0bjuvTBxVvcE6aWTf3Ug9qanfpEvh9HK2halC0BI9UY+?=
 =?us-ascii?Q?zpuNV/an02LKJu7Z13ZE8LtiTcaw56yx38tTQvMdJ9E+w2AI+w1tAUVzs0w0?=
 =?us-ascii?Q?rpelDUdoXvBGm3oODEXPwtKp3UV8Xs7SrcvpCWfFZcilGUBboKqQe1MSxf0d?=
 =?us-ascii?Q?iVSWavJLZZjcMZa5PXSzYFShtgispUJRFmwsXmpvj1BpRDwF9us3UH8sE7Ao?=
 =?us-ascii?Q?ks31/b6EUdHBU5Sh1+1lFS2RWkj2tpH0duZ3kdAyhPjkNgr8elVmE+JVdALl?=
 =?us-ascii?Q?Izt5SIJ1wUD4gts4ggsrJM2/iq0FHeivdQdyyBs8uGP3oFH59KCZC7pag+SH?=
 =?us-ascii?Q?X1R2PSVtch07T5CpWSIX3bciR4rk4CbQzOu4glXuVXD3cIFBbDAplkS2rsXN?=
 =?us-ascii?Q?QbscvreQtE/DTxsoaP78wfAyr6E4Kwv1ozU4i8QK/l9Hsgy9aiAugv0KW1rI?=
 =?us-ascii?Q?NfWqFnshanOcPEP0DuJvqX/OEJ5jWRGInqTCz0l9jGKq7V/729FoIuTwoKnj?=
 =?us-ascii?Q?1uJxE9yqOBnX9pcqgQdfeaRmwOIsepHiWmSUUrectZOADBoWmbIL1l8Cjhou?=
 =?us-ascii?Q?1dH+GKksq2/+8440CGU4yidpqUfd/120gaLX4AAs22S6+sYcfd4Eqd/Bd+mR?=
 =?us-ascii?Q?5XO7Zj7KSNouCwnso5Ai98puy7xgyW2hgddNGq/bPtcZBpaxSRyvCbKY3agd?=
 =?us-ascii?Q?clvsaRntl3JXe+SBBgkkSITIN97Y/arYJlieRBEkNbvKXn0ldiCFaHCDpHJo?=
 =?us-ascii?Q?opzxoe4weRetHRtrz2hCEzAWR6mAP+gPEUvfpV+0THq+DqA3nfT+16asBkQf?=
 =?us-ascii?Q?73b8eadrxyl53oYkhE4YCOBDNv5ZMM7vEmMvNzR7hm58e//vUAFCD/lsFz/L?=
 =?us-ascii?Q?8ygQIZB/pQCsTIJD1n8Ehxj1dvwgth78DXXeY0iIywLuB62/hFaUo+kiCdMD?=
 =?us-ascii?Q?l8Nf4IIeNnsiZ+g5SFNNZmNJxn4zrTbQjM5aVjyHIDIxUe/4v/fKpXDqHEJh?=
 =?us-ascii?Q?Qj7o+usaZXdV5yd/hNJm9zXH/etZRzKYT6ZdfRbt?=
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: DYEv3e+bQz51EIiSQcJgB0F5WX7p0MzLqhgLVF1XKYmSqsjZg0DmP/tz1iFXBpX1HkQcalCxrgV+doxz+f7SZOxDw/yINaTEbTcTAxRVNGpDxGTegwwm2TkeUng3uasmbb+QKxlaKK/FfPV0awPb+932ZRd7JWKmPNcocVjXo2pbX5++FkeDq/NeSJ+A3aNbp+2Ctu0fOgSGXbwBYAaRgbLWYJhj9FLqyLXAR6PswG+jP/V7JirO2WTkbIrlhtHJmrUZ4GgGMmer6enyTngqweRYKXLjbCU/X9HMidst5YFCrJcaFRAR/TBZVOWtM8UD7t6zsj7Taxi4ov+LntNDHZ2GjUTA06GAPgDTC+bqQlVUykYnlWmWQxJyu5xvftSBAWVzZ+sAJNpdkPpVmqkMc0caM51WTc5UliHcv+rESPanfXTKJVpLEe3LajSKu1Z2N7PRc8e6u+ggFPyTACRWONhMpccUtnFb05SQC9BnVTbLgWPkL7B5QaQfPEyaZ8G1S798wzn3qMFdhpAaMA+Cz6zXBhtfXTOi0yzDzG28UXyTN2dWnaP9m9ytkiFmiCLujP8jn16ZAJP9/WskOMC5mVrT34Jkm0Y/ePwOzfK+UOMX2DKZjHhVi22RqAQIBKQibOL15boni5RjbYpJA3ARjpADW2SkIHYgIlu98+BI4QM=
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MW4PR19MB5630.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 1bed69bb-0bc3-4644-224b-08dc1fbfdb33
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 Jan 2024 05:13:25.6392 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: R9voGgJXKyjPzDQa8JnA6rakpbA2I7sDuoYIgHc6Oe9DMPkfTPzNqMtuFkw/9ZdM
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SA0PR19MB6907
X-BESS-ID: 1706418809-110807-12457-361-1
X-BESS-VER: 2019.1_20240125.1952
X-BESS-Apparent-Source-IP: 104.47.66.40
X-BESS-Parts: H4sIAAAAAAACAzXLOwrDQAyE4buodiHty1pfJaSYXcm4CSmyRSD47tnCboafge
 /xI/8O2mjMXej9oS2lKrOOecIExfdYIJzDysyQVB1ZVDMS6Fxuf4zX5VU1Xr6pIYTSK3
 hqM+nuHOLK0prtsdP5/APpM18YgQAAAA==
X-BESS-Outbound-Spam-Score: 0.00
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.253807 [from 
 cloudscan14-36.us-east-2a.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.00 HTML_MESSAGE           BODY: HTML included in message 
 0.00 BSF_SC5_SA210e         META: Custom Rule SA210e 
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.00 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=HTML_MESSAGE, BSF_SC5_SA210e, BSF_BESS_OUTBOUND
X-BESS-BRTS-Status: 1
Subject: Re: [lustre-devel] Direct Modification of Lustre Metadata on Disk
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
From: Andreas Dilger via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Andreas Dilger <adilger@whamcloud.com>
Content-Type: multipart/mixed; boundary="===============2582087904248275182=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============2582087904248275182==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_C3A9CCEACCB141A59B40D99D2E56E535ddncom_"

--_000_C3A9CCEACCB141A59B40D99D2E56E535ddncom_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

On Jan 26, 2024, at 12:57, Saisha Kamat via lustre-devel <lustre-devel@list=
s.lustre.org<mailto:lustre-devel@lists.lustre.org>> wrote:

I am a Ph.D. student at UNC-Charlotte, focusing on research related to
the Lustre File System. As part of my project, I am investigating
scenarios involving the direct modification of xattr metadata on the
Lustre disk, without unmounting the Lustre servers.

It would be helpful to know what the high-level goal of your research is?
Is this some type of fault injection mechanism, or are you trying to store
useful data directly into the xattr, or something else?  Note that there
have already been a few papers published about this.  If you are looking
for research ideas related to Lustre I could definitely give you a few, ple=
ase
contact me if interested.  Doubly so if you actually implement something
that is useful at the end of your Ph.D. and not a throw-away project.

To achieve this, I have attempted to open the MDS (Metadata Server)
disk partition as a file descriptor, locate the target file and its
xattr, and write a faulty value. However, I have encountered an
unexpected issue where my changes appear to be saved to memory and are
not being synchronized with the disk.

In general, this is also a good way to corrupt the filesystem.  If the xatt=
r
is stored directly in the inode (as most of them are) then you will also be
overwriting the live inode that is also in memory.  In many cases, whatever
was written directly to disk will be overwritten and lost when the inode is
flushed from memory.

Alternately, if the inode is already in memory, the xattr will be read from
RAM (either from the client cache, or from the MDS cache.

If you create a large xattr it will be written to a separate block, which
would at least avoid massive filesystem corruption.

After completing the write operation, when I read the same xattr
again, it reflects the corrupted value. Strangely, when using the
"getfattr" command, the original, correct value is displayed. This
discrepancy has raised doubts about whether Lustre permits direct
modifications to its metadata on the disk.

The xattr contents are also cached on the client, and direct writes
to the storage would not invalidate that cache because they bypass
all of the proper access controls and locking.

Furthermore, I observed that even after unmounting and remounting the
Lustre file system, the xattr continues to display the corrupted value
upon reading, whereas "getfattr" still returns the original, correct
value.

That really depends on how you modified the "xattr" and where "getfattr"
is actually getting the data from.  I suspect you aren't doing what you
think you are doing.

Please help me understand whether Lustre allows direct modifications
to its metadata on the disk and if there are any inherent limitations
or considerations that I should be aware of.

No, of course Lustre and ext4 do not "allow" this.  Just like any filesyste=
m
doesn't "allow" you to run "dd if=3D/dev/zero of=3D/dev/sda1" and erase the
data from the partition.

Additionally, any recommendations or alternative approaches for
simulating faulty conditions for testing purposes would be highly
valuable to my research.

That really depends on what your research is trying to achieve.  Lustre
depends on reliable (RAID) storage underneath the MDT and OST.  It
is possible to use ldiskfs (ext4) or ZFS as underlying storage, and they
have different reliability vs. performance properties.  If you are testing
to directly corrupt on-disk storage then you are really testing those disk
filesystems, and Lustre does not add additional data redundancy layers
on top of them for metadata today, though there are *some* types of
internal metadata redundancy that can help recover from storage errors
(e.g. LFSCK can rebuild the Lustre file layout after errors on the MDT,
along with some types of directory breakage from the "link" xattr).

ZFS should be able to withstand such data/metadata block corruption
up to a certain level without any errors, until it just refuses to work at =
all.
ldiskfs would *not* be able to handle outright corruption of the on-disk
data (which is why you use RAID underneath it), but most corruption
would be localized and the filesystem would generally continue to work
(modulo the broken bits) even in the face of massive corruption.  Kind
of like the difference between digital and analog audio signals.

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Whamcloud








--_000_C3A9CCEACCB141A59B40D99D2E56E535ddncom_
Content-Type: text/html; charset="us-ascii"
Content-ID: <C410966DF8F0F242958745EEE7047E1D@namprd19.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
</head>
<body style=3D"word-wrap: break-word; -webkit-nbsp-mode: space; line-break:=
 after-white-space;" class=3D"">
On Jan 26, 2024, at 12:57, Saisha Kamat via lustre-devel &lt;<a href=3D"mai=
lto:lustre-devel@lists.lustre.org" class=3D"">lustre-devel@lists.lustre.org=
</a>&gt; wrote:
<div>
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div class=3D""><br class=3D"">
I am a Ph.D. student at UNC-Charlotte, focusing on research related to<br c=
lass=3D"">
the Lustre File System. As part of my project, I am investigating<br class=
=3D"">
scenarios involving the direct modification of xattr metadata on the<br cla=
ss=3D"">
Lustre disk, without unmounting the Lustre servers.<br class=3D"">
</div>
</div>
</blockquote>
<div><br class=3D"">
</div>
It would be helpful to know what the high-level goal of your research is?</=
div>
<div>Is this some type of fault injection mechanism, or are you trying to s=
tore</div>
<div>useful data directly into the xattr, or something else? &nbsp;Note tha=
t there</div>
<div>have already been a few papers published about this. &nbsp;If you are =
looking</div>
<div>for research ideas related to Lustre I could definitely give you a few=
, please</div>
<div>contact me if interested. &nbsp;Doubly so if you actually implement so=
mething</div>
<div>that is useful at the end of your Ph.D. and not a throw-away project.<=
/div>
<div><br class=3D"">
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div class=3D"">To achieve this, I have attempted to open the MDS (Metadata=
 Server)<br class=3D"">
disk partition as a file descriptor, locate the target file and its<br clas=
s=3D"">
xattr, and write a faulty value. However, I have encountered an<br class=3D=
"">
unexpected issue where my changes appear to be saved to memory and are<br c=
lass=3D"">
not being synchronized with the disk.<br class=3D"">
</div>
</div>
</blockquote>
<div><br class=3D"">
</div>
In general, this is also a good way to corrupt the filesystem. &nbsp;If the=
 xattr</div>
<div>is stored directly in the inode (as most of them are) then you will al=
so be</div>
<div>overwriting the live inode that is also in memory. &nbsp;In many cases=
, whatever</div>
<div>was written directly to disk will be overwritten and lost when the ino=
de is</div>
<div>flushed from memory.</div>
<div><br class=3D"">
</div>
<div>Alternately, if the inode is already in memory, the xattr will be read=
 from</div>
<div>RAM (either from the client cache, or from the MDS cache.</div>
<div><br class=3D"">
</div>
<div>If you create a large xattr it will be written to a separate block, wh=
ich</div>
<div>would at least avoid massive filesystem corruption.</div>
<div><br class=3D"">
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div class=3D"">After completing the write operation, when I read the same =
xattr<br class=3D"">
again, it reflects the corrupted value. Strangely, when using the<br class=
=3D"">
&quot;getfattr&quot; command, the original, correct value is displayed. Thi=
s<br class=3D"">
discrepancy has raised doubts about whether Lustre permits direct<br class=
=3D"">
modifications to its metadata on the disk.<br class=3D"">
</div>
</div>
</blockquote>
<div><br class=3D"">
</div>
The xattr contents are also cached on the client, and direct writes</div>
<div>to the storage would not invalidate that cache because they bypass</di=
v>
<div>all of the proper access controls and locking.</div>
<div><br class=3D"">
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div class=3D"">Furthermore, I observed that even after unmounting and remo=
unting the<br class=3D"">
Lustre file system, the xattr continues to display the corrupted value<br c=
lass=3D"">
upon reading, whereas &quot;getfattr&quot; still returns the original, corr=
ect<br class=3D"">
value.<br class=3D"">
</div>
</div>
</blockquote>
<div><br class=3D"">
</div>
That really depends on how you modified the &quot;xattr&quot; and where &qu=
ot;getfattr&quot;</div>
<div>is actually getting the data from. &nbsp;I suspect you aren't doing wh=
at you</div>
<div>think you are doing.</div>
<div><br class=3D"">
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div class=3D"">Please help me understand whether Lustre allows direct modi=
fications<br class=3D"">
to its metadata on the disk and if there are any inherent limitations<br cl=
ass=3D"">
or considerations that I should be aware of.<br class=3D"">
</div>
</div>
</blockquote>
<div><br class=3D"">
</div>
No, of course Lustre and ext4 do not &quot;allow&quot; this. &nbsp;Just lik=
e any filesystem</div>
<div>doesn't &quot;allow&quot; you to run &quot;dd if=3D/dev/zero of=3D/dev=
/sda1&quot; and erase the</div>
<div>data from the partition.</div>
<div><br class=3D"">
</div>
<div>
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div class=3D"">Additionally, any recommendations or alternative approaches=
 for<br class=3D"">
simulating faulty conditions for testing purposes would be highly<br class=
=3D"">
valuable to my research.<br class=3D"">
</div>
</div>
</blockquote>
<br class=3D"">
</div>
<div>That really depends on what your research is trying to achieve. &nbsp;=
Lustre</div>
<div>depends on reliable (RAID) storage underneath the MDT and OST. &nbsp;I=
t</div>
<div>is possible to use ldiskfs (ext4) or ZFS as underlying storage, and th=
ey</div>
<div>have different reliability vs. performance properties. &nbsp;If you ar=
e testing</div>
<div>to directly corrupt on-disk storage then you are really testing those =
disk</div>
<div>filesystems, and Lustre does not add additional data redundancy layers=
</div>
<div>on top of them for metadata today, though there are *some* types of</d=
iv>
<div>internal metadata redundancy that can help recover from storage errors=
</div>
<div>(e.g. LFSCK can rebuild the Lustre file layout after errors on the MDT=
,</div>
<div>along with some types of directory breakage from the &quot;link&quot; =
xattr).</div>
<div><br class=3D"">
</div>
<div>ZFS should be able to withstand such data/metadata block corruption</d=
iv>
<div>up to a certain level without any errors, until it just refuses to wor=
k at all.</div>
<div>ldiskfs would *not* be able to handle outright corruption of the on-di=
sk</div>
<div>data (which is why you use RAID underneath it), but most corruption</d=
iv>
<div>would be localized and the filesystem would generally continue to work=
</div>
<div>(modulo the broken bits) even in the face of massive corruption. &nbsp=
;Kind</div>
<div>of like the difference between digital and analog audio signals.</div>
<br class=3D"">
<div class=3D"">
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); =
letter-spacing: normal; text-align: start; text-indent: 0px; text-transform=
: none; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: =
0px; text-decoration: none; word-wrap: break-word; -webkit-nbsp-mode: space=
; line-break: after-white-space;" class=3D"">
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); =
letter-spacing: normal; text-align: start; text-indent: 0px; text-transform=
: none; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: =
0px; text-decoration: none; word-wrap: break-word; -webkit-nbsp-mode: space=
; line-break: after-white-space;" class=3D"">
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); =
letter-spacing: normal; text-align: start; text-indent: 0px; text-transform=
: none; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: =
0px; text-decoration: none; word-wrap: break-word; -webkit-nbsp-mode: space=
; line-break: after-white-space;" class=3D"">
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); =
letter-spacing: normal; text-align: start; text-indent: 0px; text-transform=
: none; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: =
0px; text-decoration: none; word-wrap: break-word; -webkit-nbsp-mode: space=
; line-break: after-white-space;" class=3D"">
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); =
letter-spacing: normal; text-align: start; text-indent: 0px; text-transform=
: none; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: =
0px; text-decoration: none; word-wrap: break-word; -webkit-nbsp-mode: space=
; line-break: after-white-space;" class=3D"">
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); =
letter-spacing: normal; text-align: start; text-indent: 0px; text-transform=
: none; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: =
0px; text-decoration: none; word-wrap: break-word; -webkit-nbsp-mode: space=
; line-break: after-white-space;" class=3D"">
<div>Cheers, Andreas</div>
<div>--</div>
<div>Andreas Dilger</div>
<div>Lustre&nbsp;Principal Architect</div>
<div>Whamcloud</div>
<div><br class=3D"">
</div>
<div><br class=3D"">
</div>
<div><br class=3D"">
</div>
</div>
</div>
</div>
</div>
</div>
<br class=3D"Apple-interchange-newline">
</div>
<br class=3D"Apple-interchange-newline">
<br class=3D"Apple-interchange-newline">
</div>
<br class=3D"">
</body>
</html>

--_000_C3A9CCEACCB141A59B40D99D2E56E535ddncom_--

--===============2582087904248275182==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============2582087904248275182==--

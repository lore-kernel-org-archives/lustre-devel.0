Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 26DEBC4332F
	for <lustre-devel@archiver.kernel.org>; Sun,  5 Nov 2023 06:16:37 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4SNPMT6h6xz1yCN;
	Sat,  4 Nov 2023 23:14:29 -0700 (PDT)
Received: from outbound-ip191b.ess.barracuda.com
 (outbound-ip191b.ess.barracuda.com [209.222.82.124])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4SNPLw35YJz1y7C; Sat,  4 Nov 2023 23:14:00 -0700 (PDT)
Received: from NAM12-MW2-obe.outbound.protection.outlook.com
 (mail-mw2nam12lp2040.outbound.protection.outlook.com [104.47.66.40]) by
 mx-outbound22-77.us-east-2b.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Sun, 05 Nov 2023 06:13:56 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=U/J/c0Y42cxxM0RQfuE1sph1zjeuHZhy0NKMyivALOiv8hR2x/5pdJaxka+neQEjYe6m2kY58H/ANzk+UPbt4BQS91AOpjisuX6saa0HU31e1CvYEI+HJwY9CUCBuqYaSM8QTof18uSDZ8DJH29VFm2idoJM3GwPxP3YgbbIKJ4Hx34K88eJkoASlo8YfZJvyuAfBbRYHYsBzwjqlT38QGJcNKuWiOlv5sn8D5keFf+gxqxxqQbESwAQELVqpXhfbnM+Ncfxay3S9wpVl0uVeEITkxqcuZKpFag7ufD9zjtS+skbY9GQ8koIk/Jpe9BVRZtSxpTk5Zkk98TuJbeQkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=pPohsyTd3enyhpGpQfwJkmpUkHDJx0lmnFJwf2BVZh8=;
 b=nWFnpolU6c8+HDxyP1xGRamiYlfCFrpxzcLWPT0d/zjYxg72CbsZVN/+KnADY4h6DLVVp9/XQBbcayroHdpmm+CHMcKNR/a395wROOjkrqMjFTsh4OUyr4hZuk8c1tfW3W6b1zLetzVz1tyAnAZfSQwDHIO4QIK45mEjCzUP0HklfLSvhTjMlEUl/nyd+/MxudKRGNXh0Bx3yyBY6ZjKQqstvPx94GvqLz/XeyXVBSUPjLnQ7rqol8pKyxWOLRVI5jlDbd1TudSgZTO56UiX6oL9VxQccMDvD1dydS116r1SXSbactoqe2swPscl4reXuNSAeyOX49oDj+1FdQ2GHA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=pPohsyTd3enyhpGpQfwJkmpUkHDJx0lmnFJwf2BVZh8=;
 b=KDCUQLezxIFswvQWGeDRc4crVWEQlGi10lnn1xan8OtYhWgLNfPQFo5Hb8wkti1j0GXP36zYJwJMImf07VoVOoASrgBw+ptrImyriyX/JBtCZegVOxheKGtGHfcWyFS85ohX0Aj9ryJP+eNliM6XbKrp6F9oW8X3c5mq8ZTufZE=
Received: from MW4PR19MB5630.namprd19.prod.outlook.com (2603:10b6:303:189::12)
 by MW5PR19MB5628.namprd19.prod.outlook.com (2603:10b6:303:1a2::14)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.6954.25; Sun, 5 Nov
 2023 06:13:52 +0000
Received: from MW4PR19MB5630.namprd19.prod.outlook.com
 ([fe80::5159:beb7:af36:75b3]) by MW4PR19MB5630.namprd19.prod.outlook.com
 ([fe80::5159:beb7:af36:75b3%3]) with mapi id 15.20.6954.021; Sun, 5 Nov 2023
 06:13:52 +0000
To: Lustre discussion list <lustre-discuss@lists.lustre.org>
CC: Lustre development list <lustre-devel@lists.lustre.org>
Thread-Topic: Possible change to "lfs find -size" default units?
Thread-Index: AQHaD68/jth4niBccUKc2CnV4nauWw==
Date: Sun, 5 Nov 2023 06:13:52 +0000
Message-ID: <AC27A36D-F1C1-4B48-B038-E6C91B0C0B6E@ddn.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.21)
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: MW4PR19MB5630:EE_|MW5PR19MB5628:EE_
x-ms-office365-filtering-correlation-id: 95f1e2d6-f9cd-4eea-842b-08dbddc6620d
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: c0Y2uR7fQWJaUSj0qE28WxWw5inDU0n736S0wSnb/dSCL/nvr2K9F1zrxBLck3dnZl0bTU1DaL/I7K2rCFpm9OU/CYqDIFYFHliUot1nVyKyv62UMDBJbr9Am00Zqso4z7nTE+HuFKuRpi0v43s+2AVAQ57aP3ilVSYBYQWXAPD/uX/wQFnUzMEMppfgil9eVDCCEeMxLnjYXxXNCHMa3S+JQKsIlJr9WlJ1hZpB1E9VQ6pw2v21RB7qgCxMtgCbUnIM/a7kNn9H787ujGBuV/dSs8QWCpea55PJFTcKxrWNWnh+tTs+Nunq+Cr5IGRxVyM/vot3FSa73jBm79c48FC8iZ8pSmwscMGxQedDOYFiTlD3awmtrO+LVJ7TkKn1X0tsSgsB8HCs7kxQY77Ammuuv4keAC66+2jVWI5fEZjZynFHibFWzWBOLgO6gbH6Pzp2aZ4//vAv5lkN1hPBpznjmtJ+rLNFZwUjXpYUqZDGzJDhCiZRts+GcjL+lMPxhozXrHiSn8O9Cs3McLex7uWrRDbXFL9eRvjs8uqv2N5zYKf2iITV8CrQucQHZkt/lJ0yAn+K+fzMHGJHQPtucFxwZidEY2c1oXd0plHcSI/QjtZ5p+N94KJMmY93tRfA
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MW4PR19MB5630.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230031)(396003)(136003)(366004)(39840400004)(376002)(346002)(230922051799003)(451199024)(1800799009)(64100799003)(186009)(2906002)(6486002)(4744005)(478600001)(64756008)(316002)(76116006)(66476007)(66446008)(66946007)(66556008)(6916009)(4326008)(5660300002)(450100002)(91956017)(8936002)(8676002)(6506007)(6512007)(9686003)(41300700001)(71200400001)(26005)(83380400001)(38070700009)(122000001)(38100700002)(86362001)(33656002)(36756003);
 DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?us-ascii?Q?LHq1UV7BYRrWXGRYZ+m1PJCqf4qxiEWlCO+n/6+08ZkkcpmZivZ5scYdEKVs?=
 =?us-ascii?Q?09cPGeSsqwV6uKOtTghyFmmeAsrB2VJGu6IiTvrY73n7KfbSpuOeQDN2e1kj?=
 =?us-ascii?Q?Nk/qM1Mm+v/x832sjgQRNzu3DPaQbTcEJR4q7/7GgwcyZStDT0dnbjwgTLxn?=
 =?us-ascii?Q?TUgQSkm8FwPU4kVEg1Weu2+4WSdN5cgymX1PFXZcfpP5MZbtjqrqdoagdOAN?=
 =?us-ascii?Q?0IYzRDZdMvq5rvB8tJZ0qFNJHHdma4OAb1iXq1wuifB38gBUOKqLd0yaqg1C?=
 =?us-ascii?Q?xG39KBJCrGs02SPAR3tUjwTa0gilN9dR9MfoMlwxksnKrIEble7CDds+qliR?=
 =?us-ascii?Q?vCAZu4oufoAvSaM3bxAXxF0Ly5aENRtK0+za32Pct/kHNH1O59BJXLeM2JFC?=
 =?us-ascii?Q?6d1g1s8txTKUmftJfp4fDLzuJUjER8tFGNjWsQd2LrSheVfCiVefC9ky0IQJ?=
 =?us-ascii?Q?hFa0RpKyKoGVQ6Fn/8SApn6GNQpW6jY+MWGuOAvvF/jOgp1dPlqbvbr2IFIl?=
 =?us-ascii?Q?27CS9rA6kOzRDPjALRVfrEGErVXbmJjmie5PTC0ThCSDJGdeEBHKpi30iXZ5?=
 =?us-ascii?Q?ZrIre5tbZ0n9oRPzAZRrGyM7Fv9mYyohabJ3VDtKghxYwqjcRF3aIoU0PSYm?=
 =?us-ascii?Q?RNPg7XZ0ezNpdb3CYhuHSS0C8wk353JXVYF+REcpCwItFQI+1u5Ki/MnE13H?=
 =?us-ascii?Q?6wQKHdj16X1b9sc47hLIwiRrhrPkDSichVAl090gCQr3p6lT1BrrQ6aCik5E?=
 =?us-ascii?Q?l70WpgH2ofVX/YuBnw96/Lhfv8JfYu212nhbcDFqE4AOCHy25b/Hp5YPp9zv?=
 =?us-ascii?Q?1NClrv0XFuhAL/JtqD/1GU0jNbwboHCSWvN+LFGAwf4zGrYIlDyELS4EIzkS?=
 =?us-ascii?Q?X0BsrD4J3leEvXN9Y9Kx5mbel6bUldMwc8JjaInvj+68DAy3rRn9WZZInBYZ?=
 =?us-ascii?Q?QXmJDNA7idOS0E0/tJHmGIcoN1jnWgz1QWiWgHoqnBtyOlG+kPM28XcsxNWg?=
 =?us-ascii?Q?OQIFZVhd8UCaGo8PxMws6e1sdogD5tUcj2altIDM+JbtH5fLRAMF8xo+nHgy?=
 =?us-ascii?Q?flBuoYXT4slGWXByloXwIJ76Fi6CZhzYA0PqBGhVWgZwfLPcP/eD/9jIOQUt?=
 =?us-ascii?Q?QeOpHcgEXrcxzjTP/DOgUz6JGF50aW5cSPN8k1t2OcfFrKmHif5Ci6zJjNKB?=
 =?us-ascii?Q?MsZ3fZCRjUzrdyK7uFbwhfXZVPxqYgdsVMeU4syJV7bGJdQWngDSDRZMLRs5?=
 =?us-ascii?Q?rRe0lfLfae1Xb219jPtUIwWKpK77uqOYHGKvIfcqCXEEhClIuoJ6e/w3A3q0?=
 =?us-ascii?Q?8bHOCqJZhRSXN47KciVFxcQe1LE3UJzG8NwcmC7ZRpSIzzE0xVkc7zfQZMid?=
 =?us-ascii?Q?WLIbyYuAPalsc2Ul/JdcwwYFexYpbTZOB9mm/c/XIXtIFZoy/R5U8VdClTDJ?=
 =?us-ascii?Q?gQsLD32HWzgDeuoq4jEPeznsLhzOzRWmgGxBQkhG4uUqFlje/kPoz5wsXEev?=
 =?us-ascii?Q?XLNAbPdLGY0IFMhbaFl/KOoCceEoOxLLZCskplMkz9H3N8CoqojwvOPGT941?=
 =?us-ascii?Q?mGUxFUKPyN6ySkhqPr7OeSWd3MN9WMVh16/h3VLP?=
Content-ID: <4BE337CFB049674F917575964A1702BD@namprd19.prod.outlook.com>
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: eqSVpg95Vg0+SYdHXa1HS5QYALiwONtpCohSJoi3s9Fx28nOFMtVdl/5FxPxfqE6zTfEY0IajUxrsird4ItP1pOkZI9w66ogARTFoRssz4kN9DC2vv7aUntvzDTNBKtMydmK2H9kANcRhIZPU1rQUXumEwdbxQlPr12fMW9l+ln24Li1SZFzX8qwfcncSMZ7nZhqWCBfsoLtXYadVR8ax3yFquFwsr6e2b1DX541HBO1fBjAgZKaM3N+eD9HymW1eGc0QsSFHRPnc/PJB8AIoHnFN7FaWTr9U3Yt4lkQnI3lqbH/2Pky9n0qD4IkvTTyf7lALCf4cNqeEdWgLa9oIYjlK+CbQpSRFquBmZYxhAi+YLozAb7FwKh+VwlU4LXH50Qy4j3nZa7fr9S/fTbFs7X4Yo4fasS60Q1j7CRe4LPF015TmcBBE0Dsw2WcFj2Gcj8v3HyH0AomKaWXgFDpKcDWr5WgfZgtStPG8PYopjDJMxOurgeXwTe34aAWIQAnwrpILyjYA+P0vGh+BeSuR4Aw6d8FQ1KAjTHKn46wCUoy9/4albeBM4ilwbSwOwOxPGGzHgwI5HIVL6a/EtPf2+X0loUYjNHuoQYfrQfnMKXAGhf1Jt6EEChBvm6fKKJTGsuxImMsG9Nxuk6sWbqNEOT984blP1BSWufBYZ19JatLSb3SuW1HN887y17E23lGmf4NY66nAEjJnFxGrrhGJ/3cBVvqW9nqKKjuSEEqvFR8jeXtKsOSXvU6yFO0gIZo7RNy0aqrX5pxWpfMrq6K0KqDwy+M3S6ogNPZ5b64KXi5RmO6NPytRJ/lLHic/FcS
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MW4PR19MB5630.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 95f1e2d6-f9cd-4eea-842b-08dbddc6620d
X-MS-Exchange-CrossTenant-originalarrivaltime: 05 Nov 2023 06:13:52.1103 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: kZOO4pT5NviqGBgE/9g0PtthHJhMTSh/GO2gkWKtFTEkqq2tQbms9eydnP5S5w8U
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MW5PR19MB5628
X-BESS-ID: 1699164836-105709-12349-7585-1
X-BESS-VER: 2019.1_20231024.1900
X-BESS-Apparent-Source-IP: 104.47.66.40
X-BESS-Parts: H4sIAAAAAAACA4uuVkqtKFGyUioBkjpK+cVKVuampkBGBlDM0sQ4KdUiLTnNIN
 EgJdnA1NLMIDHZ0NI8KdHA3CI1yVipNhYARXnG/UAAAAA=
X-BESS-Outbound-Spam-Score: 0.00
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.251919 [from 
 cloudscan-ea17-231.us-east-2b.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.00 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=BSF_BESS_OUTBOUND
X-BESS-BRTS-Status: 1
Subject: [lustre-devel] Possible change to "lfs find -size" default units?
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

I've recently realized that "lfs find -size N" defaults to looking for files of N *bytes* by default, unlike regular find(1) that is assuming 512-byte blocks by default if no units are given.

I'm wondering if it would be disruptive to users if the default unit for -size was changed to 512-byte blocks instead of bytes, or if it is most common to specify a unit suffix like "lfs find -size +1M" and the change would mostly be unnoticed?  I would add a 'c' suffix for compatibility with find(1) to allow specifying an exact number of chars (bytes).

On the other hand, possibly this would be *less* confusing for users that are already used to the behavior of regular "find"?

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Whamcloud







_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

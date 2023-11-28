Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 97A74C4167B
	for <lustre-devel@archiver.kernel.org>; Tue, 28 Nov 2023 19:47:40 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4SftK63TYJz1yCH;
	Tue, 28 Nov 2023 11:47:38 -0800 (PST)
Received: from BN3PR00CU001.outbound.protection.outlook.com
 (mail-eastus2azon11020002.outbound.protection.outlook.com [52.101.56.2])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4SftK40td4z1wYk
 for <lustre-devel@lists.lustre.org>; Tue, 28 Nov 2023 11:47:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=P/j5QiaibwY22vslSqfFyNp6cw0HuWFIh9ivWgeKZXc/5Qi2sjxqW9WpeXBwWxbUS0gNguojU6W67CAgJNZgkb3AnqJPbVN2OvmFiuKkjePcmAtSHcfstUhr8OfaX9eh1pSynaRrjx9BpkRidqIYujVemxM59jIXDCWArvDjzJ6Yz+9Jfkr9egkn9zvKbJzYs1Y/lehLwjy2CGqIWRrZF9no7r0hx0icHToe9cF7XaTyJVU69B5ILZZhYobATLfq5y1oIGBXwbS/sM3zJAiRY3TTDKfIi4AOX064zwZDTTqRJ+0ktqibenT6Cno2C7aWoX/nVq1P8BBDAlGwdBpJdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=a1N9R7fC2c7EMHqiIbEPvPB3G4//di0V1PBBlAlnBx8=;
 b=W35DLg0jK0j/8EnQLKkfxm++FKyEfJyaK/jy3goEkfE+7g3ojwXSW1b9glSDZRLOja3LwYM//VjswMPFZfqadb0yoQ8vFYIkx0LPOWbjss4lkkWPR7ogq8lUDkP+nIY6DncVHKIdXMlxDh2rYFbKdX+KUoAwKFRchKytlGY17y0wN3+H5oie07pbWbsKbWIOu2B7UoHnFDbcV7DE12IlkWZyOCuAC383L0MYfhja/DrJqri1+xyFON6LapVayeeBDAUIBUJt0PH9rkim7jr550AMCLBGtjj+wWJcH148sp9c2wZfcpdD6TS09IjGi7H6Tl2xTtS5mO7X6atYAprWLQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=microsoft.com; dmarc=pass action=none
 header.from=microsoft.com; dkim=pass header.d=microsoft.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=a1N9R7fC2c7EMHqiIbEPvPB3G4//di0V1PBBlAlnBx8=;
 b=dZbrjkzKl1mX6p70JWSIEDC+e0p6gXij34kps6qdTbzVvROH2U1QXkTx/dQHORWEeyrW09PhtDGRpCwn3sNicgIXjnIc02W+MyKIBUoqcnQ2O78N02P8sopR6UDLqo3AT6DyvSOC5MoBzGQDxrn7ZWMsOLgZNT3xPAVYR0iKi4Q=
Received: from CH2PR21MB1495.namprd21.prod.outlook.com (2603:10b6:610:8d::16)
 by SJ0PR21MB2071.namprd21.prod.outlook.com (2603:10b6:a03:38d::11)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.7068.6; Tue, 28 Nov
 2023 19:47:32 +0000
Received: from CH2PR21MB1495.namprd21.prod.outlook.com
 ([fe80::f82b:f52a:f6ac:94ed]) by CH2PR21MB1495.namprd21.prod.outlook.com
 ([fe80::f82b:f52a:f6ac:94ed%7]) with mapi id 15.20.7068.002; Tue, 28 Nov 2023
 19:47:32 +0000
To: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: LDISKFS-fs error: osd_iget: special inode unallocated,
 Remounting filesystem read-only
Thread-Index: AdoiMyl4aY2IfKFNTIK3sO2x22kTZg==
Date: Tue, 28 Nov 2023 19:47:32 +0000
Message-ID: <CH2PR21MB1495094E10A3B5DAD923431DBCBCA@CH2PR21MB1495.namprd21.prod.outlook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
msip_labels: MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_ActionId=d627c788-657e-4a33-872c-4daa06a176e2;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_ContentBits=0;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_Enabled=true;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_Method=Standard;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_Name=Internal;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_SetDate=2023-11-28T19:43:04Z;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_SiteId=72f988bf-86f1-41af-91ab-2d7cd011db47;
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=microsoft.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: CH2PR21MB1495:EE_|SJ0PR21MB2071:EE_
x-ms-office365-filtering-correlation-id: e659be74-e77d-42b0-dc15-08dbf04adcbb
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: EU9/nO5aBT7UMQX+Xi/Rgf4POMspXhb/6gXLgfekmIuT69TC5gkH4wCMJ+c4RkoEStlR6Y7xZ9z+Fd2OfD2BLSFsr6balRLrN0YFi/lSgEAyX0APcud0BEvF7XHyV8aF4Iw5mSYq9oxK9wUDxeb4QL2jGRw9b+22GU9h44pz5KYmlns7oBfiKQmq7GDTJs9tFwFYF8YHe++zjYJbTlQzSnohV82DTLJOE+9jmvgEkk5yjQeQ/rPdhD5C585SumadgjlmDNtgI/znDAamymnczl4sT+1gM7ZwzfHWdjD4TrRHHJW/uNvwFuuX5SSjRxvX1U+5THbngPRUF1mbHTor4xIaYYSRQM8dn++8hmwvRy/tE80tPyZvR2N9uLlyTEFFIoPh1uFALR5+OznVS8fSwzzdCJ4H+/E7TgLocHpYqdmZvplej/7aGff5VUkquICyWKKlafqWvBSGrOt5dB2jnq8nBp+dgRg5uc77JhtECffRodTSeC7c/7MHoVjzvzlw1b14po+ImAZ5W/3tQlNX7BcJPQ7wyeAFmtvVv5G7E5kWR8cBdpc2meRhFG/cqFLGQUvUlm1Th6mFkVDL0tvjUj+/nMnyFb+U6AyYI4H6RcqvAQCEXd3bmSibuItyh31CyFKYJD8DYxa7vBtEk03X0Q==
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:CH2PR21MB1495.namprd21.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230031)(376002)(39860400002)(366004)(346002)(396003)(136003)(230922051799003)(1800799012)(64100799003)(186009)(451199024)(38070700009)(55016003)(122000001)(2906002)(41300700001)(33656002)(5660300002)(86362001)(82960400001)(9686003)(71200400001)(83380400001)(82950400001)(38100700002)(6506007)(7696005)(10290500003)(478600001)(8990500004)(66446008)(76116006)(66556008)(64756008)(52536014)(6916009)(8676002)(66946007)(316002)(66476007)(8936002);
 DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?us-ascii?Q?gLtJ4sfMXzHrbbXo1UDBo8YPE5lX/X98G5LKjmgexmPd8E0x30Rxe+q2BHR1?=
 =?us-ascii?Q?vOpfedbrb58gbW4+NORvqqIaWdG6iRujkNYvUzjwYag7BVfPYoPuQbRmWb0u?=
 =?us-ascii?Q?yjlzPMV8wDhbQoT3CHE0T6gsQv/AxHCtKRFB7SZ1RY6xVEab+djdmdM823SU?=
 =?us-ascii?Q?1D8uAMViIVlzxK8hEMkvq0QIBx6Pr3NbcTLP6ZOZnTPcwbhhwEcbrbZsotls?=
 =?us-ascii?Q?A3zukB/WrDBAQL6vl4QTyqHHHa9wMssU4B/rQcnyh03Z0WUhCytVIwH3dq8l?=
 =?us-ascii?Q?vVqzOZVL1Ecea4SO+ShPBPfWV+ShKv08wGn4lXOzeK8NrqWcUUqU7WWBo/gf?=
 =?us-ascii?Q?t1zmjQjDWwVat3DZbsU2oCiaWFPiUwigwr+A8+cMQ/vRnVf8S1enr3JfVlA2?=
 =?us-ascii?Q?e/jdt7maRtPMcivKYR0dcByyQSFSTHDPEdtfkwpla2jm2uBdwO6ZM+A7bGnE?=
 =?us-ascii?Q?3R4ghd1JeU4UyIrx6wazNkMqgKKNgEdaS9Fym8DJGU2rYKFBkJZIcjqCbiDk?=
 =?us-ascii?Q?zyUjNSlimCb8vswAf91uqWrzQ0ZDDxMzGh5IaVKE0bHaodP2VXlJbbYluJEl?=
 =?us-ascii?Q?8X+l3fUc1StZOLdDCaokHkQm7MAzFZMYnoRYcTQUg9fYmBjCxoLN8hiWq4Wq?=
 =?us-ascii?Q?PdH0OhsrkehHeMHuYhpRPPzRTUko7eiBoIyl2pZQN5e2aKfW6zXXKyXXK5KV?=
 =?us-ascii?Q?/1IiNF79h0UEVbyBZt1mOp5DYOYVW/J3hJdsI4DzY5hTpZlVi2GVMEjATSbK?=
 =?us-ascii?Q?7FZGVgTr5+RueVNO9NPqnj5ehU+36K+c5re/x11CbcsZj2iWAhu26TOF4e8N?=
 =?us-ascii?Q?q/em/JQ2Mf2phg+0LcXi6hV2+/uWoWKA+dx3zW57bHGTrqdicxgdZRhDeK9E?=
 =?us-ascii?Q?dhgF1kJoCNoEqOJYp5ZObsU2sEro0MAPzNOF27H48qiuL+n1tsDoz0FnabzB?=
 =?us-ascii?Q?5n/fzy7+RN/eUbNWIJsP8WXVoM27wlSf5BiXOITDRdVKinEm5cvSoB230oWf?=
 =?us-ascii?Q?z3TOwkvcS9bqVLbMkYJHy7xcHM5QmKT7RHHVGTZ68paN7fFDpAn1Yr1wXVoz?=
 =?us-ascii?Q?vUF/ug/zXS9t6aMMS3X5LjpVEvXOk3gboN1DOuwkFd8rtqdf7H6q9j+LkCP+?=
 =?us-ascii?Q?SsKqqd0wSnqvtNeoZO82fc+ZEs4EWXfUrjCxrQhf/D3WSPIwO4aH0XWXHeOG?=
 =?us-ascii?Q?oSXKmQr7s6tqgrTC6Rx92MsMt4Siiy+8tL+wcf1jv1bz+b4FWqolMbzboz54?=
 =?us-ascii?Q?oGtlS3/5vZCnhYMacNFeB42BmDwo8njWhYbQCYF3nNq120JlgsdO5BXaihAv?=
 =?us-ascii?Q?TzCJdt/CKigI3FPgC1Oh9qaN1vK5Ti7r/cbkujExymdvNSOb7Yw9KiOhJ364?=
 =?us-ascii?Q?YrgXTQ3M4R7VYmp2hHOm45LGSA2lPF1DhCB9Cw+j53H/j343hfINKV/34dxc?=
 =?us-ascii?Q?wmtJRiPE2mZAnELldlGxVYxR6e9rqCPMjhXXRg3fQ7bIjND3xn2Xifqbqjsk?=
 =?us-ascii?Q?m6jbSfc3+Whtj2uTD4WchcEeX2+nFLNwuB+F19K+OwzvQvHICQMlTSSlm/XX?=
 =?us-ascii?Q?cx0CILqUQI7bhP3I8hFiM4unEa8j+mw3wVCTxByy?=
MIME-Version: 1.0
X-OriginatorOrg: microsoft.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: CH2PR21MB1495.namprd21.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: e659be74-e77d-42b0-dc15-08dbf04adcbb
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 Nov 2023 19:47:32.4394 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 72f988bf-86f1-41af-91ab-2d7cd011db47
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: XJIK0fKEeNFT7aZnf34E1lBt2RjktX8ubhb6JCT1o5E8kf0lJZxiCUFMgzlC3B02s33zH6B70XDiGQ8L/JPH0m000YrOy++QBZbBlOovbtE=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SJ0PR21MB2071
Subject: [lustre-devel] LDISKFS-fs error: osd_iget: special inode
 unallocated, Remounting filesystem read-only
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
From: Cyrus Ramavarapu via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Cyrus Ramavarapu <cramavarapu@microsoft.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

Hello,
 
I have recently started seeing sanity-lfsck failures in tests 18g, 23b, and 23c on Ubuntu 20.04 5.15.0-1051-azure due to the MDT filesystem going readonly preventing either the start of LFSCK or LFSCK operations. In all cases logs on the MDS show the following:
 
Nov 20 20:06:59 e72f0907-59ba-4ffd-9528-2e3ad47050e4-mdsmgs-a0-vm kernel: LDISKFS-fs error (device dm-0): osd_iget:500: inode #195: comm mdt03_003: iget: special inode unallocated Nov 20 20:06:59 e72f0907-59ba-4ffd-9528-2e3ad47050e4-mdsmgs-a0-vm kernel: Aborting journal on device dm-0-8.
Nov 20 20:06:59 e72f0907-59ba-4ffd-9528-2e3ad47050e4-mdsmgs-a0-vm kernel: LustreError: 29024:0:(osd_handler.c:1787:osd_trans_commit_cb()) transaction @0x00000000a2d278af commit error: 2 Nov 20 20:06:59 e72f0907-59ba-4ffd-9528-2e3ad47050e4-mdsmgs-a0-vm kernel: LDISKFS-fs (dm-0): Remounting filesystem read-only
 
LFSCK operations if they start will fail with error code 117 (EFSCORRUPTED):
 
00000020:00000001:8.0:1700166322.660540:0:43212:0:(lu_object.c:908:lu_object_find_at()) Process leaving (rc=18446744073709551499 : -117 : ffffffffffffff8b)
00100000:00000001:8.0:1700166322.660541:0:43212:0:(lfsck_layout.c:3241:lfsck_layout_scan_orphan_one()) Process leaving via out (rc=18446744073709551499 : -117 : 0xffffffffffffff8b)
 
In both cases, the error comes from an ldiskfs_iget operation which passes the LDISKFS_IGET_SPECIAL flag to __ext4_iget. A recent ext4 patch started checking for this flag and will return EFSCORRUPTED if the inode is unallocated (https://lkml.kernel.org/stable/20230320145452.175177331@linuxfoundation.org/ ).
 
Adding LDISKFS_IGET_SPECIAL always to ldiskfs_iget was done as part of LU-13166 (https://review.whamcloud.com/c/fs/lustre-release/+/37421 ) and feels broad to me in the context of the upstream ext4 change. At the moment I am investigating removing the LDISKFS_IGET_SPECIAL flag from ldiskfs_iget to see how it impacts the LFSCK tests and to determine if a more targeted change can be made to satisfy the intent of LU-13166.
 
Any suggestions or thoughts on how to approach this problem would be greatly appreciated. Additional logs or debugging information can be provided if needed.
 
Thank you and best,
Cyrus Ramavarapu
_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

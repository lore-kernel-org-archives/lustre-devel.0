From: =?UTF-8?Q?Jean-S=c3=a9bastien_BEVILACQUA?= <jsbevilacqua@linagora.com>
Date: Wed, 22 Jul 2020 07:59:55 -0000
Subject: [lustre-devel] Lustre optimization for billion of files
Message-ID: <ac5b89fa-3fea-01fb-8b82-eaa272b61c9b@linagora.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

I am working on adding Lustre support to Openstack Cinder and Openstack 
Swift (conception step).
I created a blueprint for Cinder here: 
https://blueprints.launchpad.net/cinder/+spec/add-lustre-driver

I am currently looking for ways to optimize the file access. For what I 
know, Lustre is better in managing few big files instead of a lot small 
files. An optimization would be to store lot of small files in one big 
file managed on Openstack side.

  * I would like to know what you thing about it ?
  * Do you have ideas about others optimizations ?
  * Do you know about optimizations on the Lustre side ?

Sincerely,
Jean-S?bastien BEVILACQUA


-- 
Jean-S?bastien BEVILACQUA>
Directeur Technique OSSA
T?l : +33(0)7 85 55 35 11
Courriel : jsbevilacqua at linagora.com
www.linagora.com

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20200722/9803a7bc/attachment.html>

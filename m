From: Nicholas Henke <nic@cray.com>
Date: Tue, 08 Jan 2008 06:31:25 -0600
Subject: [Lustre-devel] moving /proc to $MNT/.lustre
In-Reply-To: <20080107200718.GT3351@webber.adilger.int>
References: <47618E96.3080709@sun.com>	<F8F87424-C3EE-45E7-838E-95E1047F521D@Sun.COM>	<4782665E.1070406@sun.com>
	<1199729436.23325.65.camel@pc.ilinx>
	<20080107200718.GT3351@webber.adilger.int>
Message-ID: <47836D1D.1090200@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas Dilger wrote:
> 
> It wasn't mentioned here, but this is already planned.  There will be
> new commands "lctl get_param" and "lctl set_param" (or similar) that
> will be usable by scripts to get/set Lustre tunables.  This will work
> with both /proc and .../.lustre files so will allow scripts to move
> over to the new mechanism.
> 
> For user-space servers there will be no alternative but to use the lctl
> mechanism since /proc entries will not exist at all.  Then again, there
> will not be any existing systems using the old mechanism since uOSS will
> only work with ZFS.
> 

How is get_param/set_param going to work for the cases like clearing the LRU - where one might not 
know the names of all of the parameters:

for LRU in /proc/fs/lustre/ldlm/namespaces/*/lru_size; do echo clear > $LRU; done

Nic

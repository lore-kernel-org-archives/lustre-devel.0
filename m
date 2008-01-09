From: Nathan Rutman <Nathan.Rutman@Sun.COM>
Date: Tue, 08 Jan 2008 20:01:58 -0800
Subject: [Lustre-devel] moving /proc to $MNT/.lustre
In-Reply-To: <47836D1D.1090200@cray.com>
References: <47618E96.3080709@sun.com>
	<F8F87424-C3EE-45E7-838E-95E1047F521D@Sun.COM>
	<4782665E.1070406@sun.com> <1199729436.23325.65.camel@pc.ilinx>
	<20080107200718.GT3351@webber.adilger.int> <47836D1D.1090200@cray.com>
Message-ID: <47844736.8020304@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nicholas Henke wrote:
> Andreas Dilger wrote:
>>
>> It wasn't mentioned here, but this is already planned.  There will be
>> new commands "lctl get_param" and "lctl set_param" (or similar) that
>> will be usable by scripts to get/set Lustre tunables.  This will work
>> with both /proc and .../.lustre files so will allow scripts to move
>> over to the new mechanism.
>>
>> For user-space servers there will be no alternative but to use the lctl
>> mechanism since /proc entries will not exist at all.  Then again, there
>> will not be any existing systems using the old mechanism since uOSS will
>> only work with ZFS.
>>
>
> How is get_param/set_param going to work for the cases like clearing 
> the LRU - where one might not know the names of all of the parameters:
>
> for LRU in /proc/fs/lustre/ldlm/namespaces/*/lru_size; do echo clear > 
> $LRU; done
>
> Nic
In this particular case, there will not be a "namespaces" subdirectory 
-- there will be different files in the .lustre directories of different 
mount points:
/mnt/test/.lustre/ldlm/lru_size
/mnt/fast2/.lustre/ldlm/lru_size
etc

But in general, if there are any non-predefined path names for userspace 
server parameters, we'll have to add a lctl method of listing them.

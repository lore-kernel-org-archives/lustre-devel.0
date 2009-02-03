From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Tue, 03 Feb 2009 18:01:58 +0300
Subject: [Lustre-devel] Sub Tree lock ideas.
In-Reply-To: <7D9ABF96-6BD8-4F7A-A5AE-F08BF04854B2@sun.com>
References: <7D9ABF96-6BD8-4F7A-A5AE-F08BF04854B2@sun.com>
Message-ID: <18824.23654.85292.845625@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Oleg Drokin writes:
 > Hello!
 > 
 >     We discussed a bit of this in Beijing last week, but decided to  
 > continue the discussion via email.
 > 
 >     So, I think it is a given we do not want to revoke a subtree lock  
 > every time somebody steps through it, because that will be too costly  
 > in a lot of cases.
 > 
 >     Anyway here is what I have in mind.
 > 
 >     STL locks could be granted by server regardless if they were  
 > requested by the client or not.
 > 
 >     We would require clients to provide a lock "cookie" with every  
 > operation they perform, in normal case that would be a handle they  
 > have on a parent directory.
 >     This cookie should allow a way to find out what server this cookie  
 > originates from (needed for CMD support).
 > 
 >     For the case of a different client stepping into area covered by  
 > STL lock, this client would get STL lock's cookie and will start  
 > present it for all subsequent
 >     operations (also a special flag meaning that the client is not  
 > operating within STL).

How is it determined that a given point in a namespace is covered by an
STL lock? E.g., client A holds an STL on /a, and client B accesses
/a/b/c/f (where /a/b/c is a working directory of some process on B)?
This looks especially problematic in the CMD case.

Nikita.

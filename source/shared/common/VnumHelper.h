#ifndef __HEADER_VNUM_HELPER__
#define	__HEADER_VNUM_HELPER__

/**
	�̹� x���ϰų� ��8�� �߰��� ������, �� ��; �ҽ����� �ĺ��� �� ����� ���
	�ĺ���(����=VNum)�� �ϵ��ڵ��ϴ� ���8�� �Ǿ��־ �������� �ſ� ������µ�

	��8�δ� �ҽ��� �u� � ������(Ȥ: ��)���� �� �� �ְ� ���ڴ� ��ö���� f��8�� �߰�.

		* �� ����: ������ ��;��8�� ����Ǵµ� PCH�� ��8�� �ٲ� ������ ��ü ������ �ؾ��ϴ� 
		�ϴ�: �ʿ��� cpp���Ͽ��� include �ؼ� ������ ��=.

		* cpp���� �����ϸ� ������ ~ ��ũ�ؾ��ϴ� �׳� common�� ��� �־�=. (game, db�w�gƮ �� �� ��� ��d)

	@date	2011. 8. 29.
*/


class CItemVnumHelper
{
public:
	/// ���� DVD�� �һ�v ��ȯ��
	static	const bool	IsPhoenix(DWORD vnum)				{ return 53001 == vnum; }		// NOTE: �һ�v ��ȯ ������: 53001 ���� mob-vnum: 34001 �Դϴ�.

	/// �󸶴� �̺�Ʈ �ʽ´��� ���� (������ �󸶴� �̺�Ʈ�� Ư�� �������̾�8�� ��8�� ���� ����8�� ��Ȱ���ؼ� ��� ���ٰ� ��)
	static	const bool	IsRamadanMoonRing(DWORD vnum)		{ return 71135 == vnum; }

	/// �ҷ�) ���� (����: �ʽ´��� ����� ����)
	static	const bool	IsHalloweenCandy(DWORD vnum)		{ return 71136 == vnum; }

	/// ũ�������� �ູ�� ����
	static	const bool	IsHappinessRing(DWORD vnum)		{ return 71143 == vnum; }

	/// �߷�Ÿ�� ����� �Ҵ�Ʈ 
	static	const bool	IsLovePendant(DWORD vnum)		{ return 71145 == vnum; }
};

class CMobVnumHelper
{
public:
	/// ���� DVD�� �һ�v �� ��ȣ
	static	bool	IsPhoenix(DWORD vnum)				{ return 34001 == vnum; }
	static	bool	IsIcePhoenix(DWORD vnum)				{ return 34003 == vnum; }
	/// PetSystem�� �����ϴ� ���ΰ�?
	static	bool	IsPetUsingPetSystem(DWORD vnum)	{ return (IsPhoenix(vnum) || IsReindeerYoung(vnum)) || IsIcePhoenix(vnum); }

	/// 2011�� ũ�������� �̺�Ʈ�� �� (�Ʊ� ����)
	static	bool	IsReindeerYoung(DWORD vnum)	{ return 34002 == vnum; }

	/// �󸶴� �̺�Ʈ ����� �渶(20119) .. �ҷ�) �̺�Ʈ�� �󸶴� �渶 Ŭ��(����: ��=, 20219)
	static	bool	IsRamadanBlackHorse(DWORD vnum)		{ return 20119 == vnum || 20219 == vnum || 22022 == vnum; }
};

class CVnumHelper
{
};


#endif	//__HEADER_VNUM_HELPER__
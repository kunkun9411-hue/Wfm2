#include "StdAfx.h"
#include "PythonEventManager.h"
#include "PythonNetworkStream.h"

PyObject * eventRegisterEventSet(PyObject * poSelf, PyObject * poArgs)
{
	char * szFileName;
	if (!PyTuple_GetString(poArgs, 0, &szFileName))
		return Py_BuildException();

	int iEventIndex = CPythonEventManager::Instance().RegisterEventSet(szFileName);
	return Py_BuildValue("i", iEventIndex);
}

PyObject * eventRegisterEventSetFromString(PyObject * poSelf, PyObject * poArgs)
{
	char * szEventString;
	if (!PyTuple_GetString(poArgs, 0, &szEventString))
		return Py_BuildException();

	int iEventIndex = CPythonEventManager::Instance().RegisterEventSetFromString(szEventString);
	return Py_BuildValue("i", iEventIndex);
}

PyObject * eventClearEventSet(PyObject * poSelf, PyObject * poArgs)
{
	int iIndex;
	if (!PyTuple_GetInteger(poArgs, 0, &iIndex))
		return Py_BuildException();

	CPythonEventManager::Instance().ClearEventSeti(iIndex);
	return Py_BuildNone();
}

PyObject * eventSetRestrictedCount(PyObject * poSelf, PyObject * poArgs)
{
	int iIndex;
	if (!PyTuple_GetInteger(poArgs, 0, &iIndex))
		return Py_BuildException();

	int iCount;
	if (!PyTuple_GetInteger(poArgs, 1, &iCount))
		return Py_BuildException();

	CPythonEventManager::Instance().SetRestrictedCount(iIndex, iCount);
	return Py_BuildNone();
}

PyObject * eventGetEventSetLocalYPosition(PyObject * poSelf, PyObject * poArgs)
{
	int iIndex;
	if (!PyTuple_GetInteger(poArgs, 0, &iIndex))
		return Py_BuildException();

	return Py_BuildValue("i", CPythonEventManager::Instance().GetEventSetLocalYPosition(iIndex));
}

PyObject * eventAddEventSetLocalYPosition(PyObject * poSelf, PyObject * poArgs)
{
	int iIndex;
	if (!PyTuple_GetInteger(poArgs, 0, &iIndex))
		return Py_BuildException();
	int iPos;
	if (!PyTuple_GetInteger(poArgs, 1, &iPos))
		return Py_BuildException();

	CPythonEventManager::Instance().AddEventSetLocalYPo